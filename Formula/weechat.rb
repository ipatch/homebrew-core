class Weechat < Formula
  desc "Extensible IRC client"
  homepage "https://www.weechat.org"
  url "https://weechat.org/files/src/weechat-2.0.1.tar.xz"
  sha256 "6943582eabbd8a6fb6dca860a86f896492cae5fceacaa396dbc9eeaa722305d1"
  head "https://github.com/weechat/weechat.git"

  bottle do
    sha256 "86f9c7062cd5f4ca6625b175144ec37b55f462a9463a3f9852d74f56b404302b" => :high_sierra
    sha256 "1655ae54d7be8e9617c7d65d7ccc3f25e3ea1cd93d301b3ccb2d4fd056029db7" => :sierra
    sha256 "e8070f500a5f922b3f862ea67104ee9e8c7dd0f929caf408700c664ef07bfb7a" => :el_capitan
  end

  option "with-python", "Build the python module"
  option "with-perl", "Build the perl module"
  option "with-ruby", "Build the ruby module"
  option "with-curl", "Build with brewed curl"
  option "with-debug", "Build with debug information"
  option "without-tcl", "Do not build the tcl module"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "gnutls"
  depends_on "libgcrypt"
  depends_on "gettext"
  depends_on "aspell" => :optional
  depends_on "lua" => :optional
  depends_on :ruby => ["2.1", :optional]
  depends_on :perl => ["5.3", :optional]
  depends_on "curl" => :optional
  depends_on "php71" if build.with? "python"
  depends_on "php71" if build.with? "python3"

  if MacOS.version >= :mavericks
    option "with-custom-python", "Build with a custom Python 2 instead of the Homebrew version."
  end

  depends_on :python => :optional
  depends_on :python3 => :optional

  def install

    # weechat doesn't have or require any Python package,
    # to the best of my knowledge, so unset PYTHONPATH

    # -CMAKE_INSTALL_PREFIX=#{HOMEBREW_PREFIX}

    ENV.delete("PYTHONPATH")

    args = std_cmake_args + %W[
      -DENABLE_GUILE=OFF
      -DCA_FILE=#{etc}/openssl/cert.pem
      -DENABLE_JAVASCRIPT=OFF

    ]
    if build.with? "debug"
      args -= %w[-DCMAKE_BUILD_TYPE=Release]
      args << "-DCMAKE_BUILD_TYPE=Debug"
    end

    # Allow python or python3, but not both; if the optional
    # python is chosen, default to it; otherwise, use python3

    # NOTE: weechat still prefers python 2 supprot because
    # because many scripts are not compatible with python 3.

    if build.with? "python"
      ENV.prepend "LDFLAGS", `python-config --ldflags`.chomp

      framework_script = <<~EOS
        import sysconfig
        print sysconfig.get_config_var("PYTHONFRAMEWORKPREFIX")
      EOS
      framework_prefix = `python -c '#{framework_script}'`.strip
      # Non-framework builds should have PYTHONFRAMEWORKPREFIX defined as ""
      if framework_prefix.include?("/") && framework_prefix != "/System/Library/Frameworks"
        ENV.prepend "LDFLAGS", "-F#{framework_prefix}"
        ENV.prepend "CFLAGS", "-F#{framework_prefix}"
      end
      args << "-DENABLE_PYTHON=ON"
    elsif build.with? "python"
      args << "-DENABLE_PYTHON3=ON"
    end

    args << "-DENABLE_LUA=OFF" if build.without? "lua"
    args << "-DENABLE_PERL=OFF" if build.without? "perl"
    args << "-DENABLE_RUBY=OFF" if build.without? "ruby"
    args << "-DENABLE_ASPELL=OFF" if build.without? "aspell"
    args << "-DENABLE_TCL=OFF" if build.without? "tcl"
    args << "-DENABLE_PYTHON=OFF" if build.without? "python"

    mkdir "build" do
      system "cmake", "..", *args
      system "make", "install"
    end
  end

  def caveats
    if build.with?("python") && build.with?("python3")
      <<~EOS
        weechat should only built with either python 2 or python 3. Not both
        versions of python.
      EOS
    end
    <<~EOS
      Weechat can depend on Aspell if you choose the --with-aspell option, but
      Aspell should be installed manually before installing Weechat so that
      you can choose the dictionaries you want.  If Aspell was installed
      automatically as part of weechat, there won't be any dictionaries.
    EOS
  end

  test do
    system "#{bin}/weechat", "-r", "/quit"
  end
end
