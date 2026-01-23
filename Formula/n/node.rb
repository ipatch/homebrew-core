class Node < Formula
  desc "Open-source, cross-platform JavaScript runtime environment"
  homepage "https://nodejs.org/"
  url "https://nodejs.org/dist/v25.2.1/node-v25.2.1.tar.xz"
  sha256 "aa7c4ac1076dc299a8949b8d834263659b2408ec0e5bba484673a8ce0766c8b9"
  license "MIT"
  head "https://github.com/nodejs/node.git", branch: "main"

  livecheck do
    url "https://nodejs.org/dist/"
    regex(%r{href=["']?v?(\d+(?:\.\d+)+)/?["' >]}i)
  end

  depends_on "pkgconf" => :build
  depends_on "python@3.13" => :build

  # On older macOS, we need Homebrew LLVM for modern C++ support
  on_macos do
    if DevelopmentTools.clang_build_version <= 1699
      depends_on "llvm" => :build
      depends_on "openssl@3"
    else
      # Only use shared deps on newer macOS with compatible libc++
      depends_on "brotli"
      depends_on "c-ares"
      depends_on "icu4c@78"
      depends_on "libnghttp2"
      depends_on "libnghttp3"
      depends_on "libngtcp2"
      depends_on "libuv"
      depends_on "openssl@3"
      depends_on "simdjson"
      depends_on "sqlite"
      depends_on "uvwasi"
      depends_on "zstd"
    end
  end

  on_linux do
    depends_on "brotli"
    depends_on "c-ares"
    depends_on "icu4c@78"
    depends_on "libnghttp2"
    depends_on "libnghttp3"
    depends_on "libngtcp2"
    depends_on "libuv"
    depends_on "openssl@3"
    depends_on "simdjson"
    depends_on "sqlite"
    depends_on "uvwasi"
    depends_on "zstd"
  end

  uses_from_macos "python"
  uses_from_macos "zlib"

  # Patch common.gypi to remove hardcoded MACOSX_DEPLOYMENT_TARGET=13.5
  # and add _DARWIN_C_SOURCE for better compatibility with older macOS
  patch :DATA

  link_overwrite "bin/npm", "bin/npx"

  fails_with :clang do
    build 1699
    cause "needs SFINAE-friendly std::pointer_traits"
  end

  fails_with :gcc do
    version "11"
    cause "needs GCC 12 or newer"
  end

  resource "npm" do
    url "https://registry.npmjs.org/npm/-/npm-11.6.2.tgz"
    sha256 "585f95094ee5cb2788ee11d90f2a518a7c9ef6e083fa141d0b63ca3383675a20"
  end

  def use_homebrew_llvm?
    OS.mac? && DevelopmentTools.clang_build_version <= 1699
  end

  def install
    # Make sure subprocesses spawned by make are using our Python 3
    ENV["PYTHON"] = which("python3.13")

    # On older macOS (Big Sur and earlier), use Homebrew LLVM with its libc++
    if use_homebrew_llvm?
      llvm = Formula["llvm"]
      @libcxx_path = "#{llvm.opt_lib}/c++"
      @llvm_include_path = "#{llvm.opt_include}/c++/v1"
      @llvm_cc = "#{llvm.opt_bin}/clang"
      @llvm_cxx = "#{llvm.opt_bin}/clang++"
      
      # Compile-only flags (no linker flags here to avoid warnings)
      @llvm_cxxflags = [
        "-stdlib=libc++",
        "-nostdinc++",
        "-isystem#{llvm.opt_include}/c++/v1",
      ].join(" ")
      
      # Link-only flags - use FULL PATHS to dylibs to bypass SDK .tbd stubs
      # The macOS SDK contains .tbd stub files that redirect -lc++ to system libc++
      # even when we specify -L paths. Using full paths bypasses this entirely.
      @libcxx_dylib = "#{@libcxx_path}/libc++.dylib"
      @libcxxabi_dylib = "#{@libcxx_path}/libc++abi.dylib"
      @llvm_ldflags = "-Wl,-rpath,#{@libcxx_path} #{@libcxx_dylib} #{@libcxxabi_dylib}"
      
      # For macOS < 10.10 (Yosemite), disable pthread QoS APIs
      # Big Sur (11.x) should have them, but we include this for safety
      if MacOS.version < :yosemite
        @llvm_cxxflags += " -DNOT_ON_BROSEMITE_OR_LATER=1"
      end
      
      # Set environment variables - configure reads these
      ENV["CC"] = @llvm_cc
      ENV["CXX"] = @llvm_cxx
      ENV["CC_host"] = @llvm_cc
      ENV["CXX_host"] = @llvm_cxx
      ENV["CFLAGS"] = ""
      ENV["CXXFLAGS"] = @llvm_cxxflags
      ENV["LDFLAGS"] = @llvm_ldflags
      ENV["GYP_DEFINES"] = "clang=1 host_clang=1"
      
      # These are used by gyp for host tools
      ENV["CC.host"] = @llvm_cc
      ENV["CXX.host"] = @llvm_cxx
      ENV["LINK"] = @llvm_cxx
      ENV["LINK.host"] = @llvm_cxx
      
      ohai "Using Homebrew LLVM #{llvm.version} for C++20 support"
      ohai "CC=#{@llvm_cc}"
      ohai "CXXFLAGS=#{@llvm_cxxflags}"
      ohai "LDFLAGS=#{@llvm_ldflags}"
    end

    args = %W[
      --prefix=#{prefix}
      --without-npm
      --shared
      --openssl-use-def-ca-store
    ]

    if use_homebrew_llvm?
      # On older macOS, use bundled dependencies to avoid libc++ ABI mismatches
      # Only use system OpenSSL since it's C, not C++
      args += %W[
        --with-intl=full-icu
        --shared-openssl
        --shared-openssl-includes=#{Formula["openssl@3"].include}
        --shared-openssl-libpath=#{Formula["openssl@3"].lib}
        --shared-zlib
      ]
      
      ohai "Using bundled dependencies for libc++ ABI compatibility"
    else
      # On newer macOS and Linux, use shared Homebrew dependencies
      %w[brotli icu-small nghttp2 ngtcp2 npm simdjson sqlite uvwasi zstd].each do |dep|
        rm_r buildpath/"deps"/dep
      end

      args += %W[
        --with-intl=system-icu
        --shared-brotli
        --shared-cares
        --shared-libuv
        --shared-nghttp2
        --shared-nghttp3
        --shared-ngtcp2
        --shared-openssl
        --shared-simdjson
        --shared-sqlite
        --shared-uvwasi
        --shared-zlib
        --shared-zstd
        --shared-brotli-includes=#{Formula["brotli"].include}
        --shared-brotli-libpath=#{Formula["brotli"].lib}
        --shared-cares-includes=#{Formula["c-ares"].include}
        --shared-cares-libpath=#{Formula["c-ares"].lib}
        --shared-libuv-includes=#{Formula["libuv"].include}
        --shared-libuv-libpath=#{Formula["libuv"].lib}
        --shared-nghttp2-includes=#{Formula["libnghttp2"].include}
        --shared-nghttp2-libpath=#{Formula["libnghttp2"].lib}
        --shared-nghttp3-includes=#{Formula["libnghttp3"].include}
        --shared-nghttp3-libpath=#{Formula["libnghttp3"].lib}
        --shared-ngtcp2-includes=#{Formula["libngtcp2"].include}
        --shared-ngtcp2-libpath=#{Formula["libngtcp2"].lib}
        --shared-openssl-includes=#{Formula["openssl@3"].include}
        --shared-openssl-libpath=#{Formula["openssl@3"].lib}
        --shared-simdjson-includes=#{Formula["simdjson"].include}
        --shared-simdjson-libpath=#{Formula["simdjson"].lib}
        --shared-sqlite-includes=#{Formula["sqlite"].include}
        --shared-sqlite-libpath=#{Formula["sqlite"].lib}
        --shared-uvwasi-includes=#{Formula["uvwasi"].include}/uvwasi
        --shared-uvwasi-libpath=#{Formula["uvwasi"].lib}
        --shared-zstd-includes=#{Formula["zstd"].include}
        --shared-zstd-libpath=#{Formula["zstd"].lib}
      ]
    end

    args << "--tag=head" if build.head?

    system "./configure", *args
    
    # Pass compiler flags directly to make (like MacPorts does)
    # This is more reliable than environment variables for gyp
    if use_homebrew_llvm?
      # Patch the main Makefile to pass variables to sub-make
      # The top-level Makefile runs: $(MAKE) -C out BUILDTYPE=Release
      # We need to add our compiler variables to that command
      main_makefile = buildpath/"Makefile"
      if main_makefile.exist?
        content = main_makefile.read
        
        # Find lines that call sub-make and add variable passing
        # The pattern is typically: $(MAKE) -C out BUILDTYPE=...
        replacement_vars = [
          "CC='#{@llvm_cc}'",
          "CXX='#{@llvm_cxx}'",
          "CC_host='#{@llvm_cc}'",
          "CXX_host='#{@llvm_cxx}'",
          "LINK='#{@llvm_cxx}'",
          "LINK_host='#{@llvm_cxx}'",
          "CXXFLAGS='#{@llvm_cxxflags}'",
          "LDFLAGS='#{@llvm_ldflags}'",
        ].join(" ")
        
        content = content.gsub(
          /(\$\(MAKE\)\s+-C\s+out\s+BUILDTYPE=\S+)/,
          "\\1 #{replacement_vars}"
        )
        main_makefile.atomic_write(content)
        ohai "Patched top-level Makefile to pass compiler variables to sub-make"
      end
      
      # CRITICAL: Patch all .host.mk files to add libc++ to their link commands
      # These files control how host tools like js2c are built
      # gyp generates these and they don't honor LDFLAGS or CXXFLAGS
      Dir.glob(buildpath/"out/**/*.host.mk").each do |mk_file|
        content = File.read(mk_file)
        modified = false
        
        # Add our include flags to CFLAGS_CC_Release for C++ compilation
        # This ensures host tools use LLVM's libc++ headers, not system headers
        if content =~ /^CFLAGS_CC_Release\s*:=/
          content = content.gsub(
            /^(CFLAGS_CC_Release\s*:=.*?)-std=gnu\+\+20/m,
            "\\1-std=gnu++20 -nostdinc++ -isystem#{@llvm_include_path}"
          )
          modified = true
        end
        
        # Also patch Debug configuration
        if content =~ /^CFLAGS_CC_Debug\s*:=/
          content = content.gsub(
            /^(CFLAGS_CC_Debug\s*:=.*?)-std=gnu\+\+20/m,
            "\\1-std=gnu++20 -nostdinc++ -isystem#{@llvm_include_path}"
          )
          modified = true
        end
        
        # Add our library flags to LDFLAGS_host or create it
        if content.include?("LDFLAGS_host")
          content = content.gsub(
            /^(LDFLAGS_host\s*:=\s*)/,
            "\\1-L#{@libcxx_path} -Wl,-rpath,#{@libcxx_path} "
          )
          modified = true
        end
        
        # Fix LIBS - use FULL PATHS to libc++ dylibs instead of -lc++
        # This is critical because the macOS SDK contains .tbd stubs that redirect
        # -lc++ to the system libc++, even when we specify -L paths first.
        # By using full paths, we bypass the linker's library search entirely.
        # (@libcxx_dylib and @libcxxabi_dylib are defined at the top of this block)
        
        if content =~ /^LIBS\s*:=/
          # Replace LIBS := \ with LIBS := /path/to/libc++.dylib \ 
          # or LIBS := -lfoo with LIBS := /path/to/libc++.dylib -lfoo
          content = content.gsub(
            /^(LIBS\s*:=\s*)(\\?)(\s*)$/,
            "\\1-Wl,-rpath,#{@libcxx_path} #{@libcxx_dylib} #{@libcxxabi_dylib} \\2\\3"
          )
          # Also handle LIBS := -lfoo (no continuation)
          content = content.gsub(
            /^(LIBS\s*:=\s*)(-[^\\\n])/,
            "\\1-Wl,-rpath,#{@libcxx_path} #{@libcxx_dylib} #{@libcxxabi_dylib} \\2"
          )
          modified = true
        end
        
        File.write(mk_file, content) if modified
      end
      ohai "Patched #{Dir.glob(buildpath/"out/**/*.host.mk").count} .host.mk files with libc++ flags"
      
      # Also patch the main out/Makefile to add LIBS with full paths
      out_makefile = buildpath/"out/Makefile"
      if out_makefile.exist?
        content = out_makefile.read
        
        # Find the LIBS line and prepend our libraries using full paths
        if content.include?("LIBS :=")
          content = content.gsub(
            /^(LIBS\s*:=)/,
            "\\1 #{@libcxx_dylib} #{@libcxxabi_dylib}"
          )
        else
          # Add LIBS if it doesn't exist
          content = "LIBS := #{@libcxx_dylib} #{@libcxxabi_dylib}\n" + content
        end
        
        out_makefile.atomic_write(content)
        ohai "Patched out/Makefile with LIBS"
      end
      
      system "make", "-j1", "install", "V=1"
    else
      system "make", "install"
    end

    # Allow npm to find Node before installation has completed.
    ENV.prepend_path "PATH", bin

    bootstrap = buildpath/"npm_bootstrap"
    bootstrap.install resource("npm")
    # These dirs must exist before npm install.
    mkdir_p libexec/"lib"
    system "node", bootstrap/"bin/npm-cli.js", "install", "-ddd", "--global",
            "--prefix=#{libexec}", resource("npm").cached_download

    # The `package.json` stores integrity information about the above passed
    # in `cached_download` npm resource, which breaks `npm -g outdated npm`.
    # This copies back over the vanilla `package.json` to fix this issue.
    cp bootstrap/"package.json", libexec/"lib/node_modules/npm"

    # These symlinks are never used & they've caused issues in the past.
    rm_r libexec/"share" if (libexec/"share").exist?

    # Create temporary npm and npx symlinks until post_install is done.
    ln_s libexec/"lib/node_modules/npm/bin/npm-cli.js", bin/"npm"
    ln_s libexec/"lib/node_modules/npm/bin/npx-cli.js", bin/"npx"

    generate_completions_from_executable(bin/"npm", "completion",
                                         shells:                 [:bash, :zsh],
                                         shell_parameter_format: :none)
  end

  def post_install
    node_modules = HOMEBREW_PREFIX/"lib/node_modules"
    node_modules.mkpath
    # Remove npm but preserve all other modules across node updates/upgrades.
    rm_r node_modules/"npm" if (node_modules/"npm").exist?

    cp_r libexec/"lib/node_modules/npm", node_modules
    ln_sf node_modules/"npm/bin/npm-cli.js", bin/"npm"
    ln_sf node_modules/"npm/bin/npx-cli.js", bin/"npx"
    ln_sf bin/"npm", HOMEBREW_PREFIX/"bin/npm"
    ln_sf bin/"npx", HOMEBREW_PREFIX/"bin/npx"

    %w[man1 man5 man7].each do |man|
      mkdir_p HOMEBREW_PREFIX/"share/man/#{man}"
      rm(Dir[HOMEBREW_PREFIX/"share/man/#{man}/{npm.,npm-,npmrc.,package.json.,npx.}*"])
      ln_sf Dir[node_modules/"npm/man/#{man}/{npm,package-,shrinkwrap-,npx}*"], HOMEBREW_PREFIX/"share/man/#{man}"
    end

    (node_modules/"npm/npmrc").atomic_write("prefix = #{HOMEBREW_PREFIX}\n")
  end

  def caveats
    if use_homebrew_llvm?
      <<~EOS
        This build uses Homebrew LLVM's libc++ for C++20 support on older macOS.
        The node binary has an rpath set to find the correct libc++ at runtime.
        
        If you see C++ ABI errors with native npm modules, you may need to
        rebuild them or ensure they're compiled with the same toolchain.
      EOS
    end
  end

  test do
    path = testpath/"test.js"
    path.write "console.log('hello');"

    output = shell_output("#{bin}/node #{path}").strip
    assert_equal "hello", output
    output = shell_output("#{bin}/node -e 'console.log(new Intl.NumberFormat(\"en-EN\").format(1234.56))'").strip
    assert_equal "1,234.56", output

    output = shell_output("#{bin}/node -e 'console.log(new Intl.NumberFormat(\"de-DE\").format(1234.56))'").strip
    assert_equal "1.234,56", output

    # make sure npm can find node
    ENV.prepend_path "PATH", opt_bin
    ENV.delete "NVM_NODEJS_ORG_MIRROR"
    assert_equal which("node"), opt_bin/"node"
    assert_path_exists HOMEBREW_PREFIX/"bin/npm", "npm must exist"
    assert_predicate HOMEBREW_PREFIX/"bin/npm", :executable?, "npm must be executable"
    npm_args = ["-ddd", "--cache=#{HOMEBREW_CACHE}/npm_cache", "--build-from-source"]
    system HOMEBREW_PREFIX/"bin/npm", *npm_args, "install", "npm@latest"
    system HOMEBREW_PREFIX/"bin/npm", *npm_args, "install", "nan"
    assert_path_exists HOMEBREW_PREFIX/"bin/npx", "npx must exist"
    assert_predicate HOMEBREW_PREFIX/"bin/npx", :executable?, "npx must be executable"
    assert_match "< hello >", shell_output("#{HOMEBREW_PREFIX}/bin/npx --yes cowsay hello")
  end
end

__END__
diff --git a/common.gypi b/common.gypi
--- a/common.gypi
+++ b/common.gypi
@@ -621,7 +621,8 @@
         ],
       }],
       ['OS=="mac"', {
-        'defines': ['_DARWIN_USE_64_BIT_INODE=1'],
+        'defines': ['_DARWIN_USE_64_BIT_INODE=1',
+                    '_DARWIN_C_SOURCE=1'],
         'xcode_settings': {
           'ALWAYS_SEARCH_USER_PATHS': 'NO',
           'GCC_CW_ASM_SYNTAX': 'NO',                # No -fasm-blocks
@@ -632,7 +633,6 @@
           'GCC_ENABLE_PASCAL_STRINGS': 'NO',        # No -mpascal-strings
           'GCC_STRICT_ALIASING': 'NO',              # -fno-strict-aliasing
           'PREBINDING': 'NO',                       # No -Wl,-prebind
-          'MACOSX_DEPLOYMENT_TARGET': '13.5',       # -mmacosx-version-min=13.5
           'USE_HEADERMAP': 'NO',
           'WARNING_CFLAGS': [
             '-Wall',
diff --git a/deps/v8/src/base/platform/platform-posix.cc b/deps/v8/src/base/platform/platform-posix.cc
--- a/deps/v8/src/base/platform/platform-posix.cc
+++ b/deps/v8/src/base/platform/platform-posix.cc
@@ -1135,6 +1135,7 @@
   SetThreadName(thread->name());
 #if V8_OS_DARWIN
   switch (thread->priority()) {
+#ifndef NOT_ON_BROSEMITE_OR_LATER
     case Thread::Priority::kBestEffort:
       pthread_set_qos_class_self_np(QOS_CLASS_BACKGROUND, 0);
       break;
@@ -1144,6 +1145,7 @@
     case Thread::Priority::kUserBlocking:
       pthread_set_qos_class_self_np(QOS_CLASS_USER_INITIATED, 0);
       break;
+#endif
     case Thread::Priority::kDefault:
       break;
   }
diff --git a/deps/v8/src/d8/d8.cc b/deps/v8/src/d8/d8.cc
--- a/deps/v8/src/d8/d8.cc
+++ b/deps/v8/src/d8/d8.cc
@@ -5696,6 +5696,7 @@
 
   v8::V8::InitializeICUDefaultLocation(argv[0], options.icu_data_file);
 
+#ifndef NOT_ON_BROSEMITE_OR_LATER
 #ifdef V8_OS_DARWIN
   if (options.apply_priority) {
     struct task_category_policy category = {.role =
@@ -5705,6 +5706,7 @@
     pthread_set_qos_class_self_np(QOS_CLASS_USER_INTERACTIVE, 0);
   }
 #endif
+#endif
 
 #ifdef V8_INTL_SUPPORT
   if (options.icu_locale != nullptr) {
