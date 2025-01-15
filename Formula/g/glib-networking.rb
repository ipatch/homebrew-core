class GlibNetworking < Formula
  desc "Network related modules for glib"
  homepage "https://gitlab.gnome.org/GNOME/glib-networking"
  url "https://download.gnome.org/sources/glib-networking/2.80/glib-networking-2.80.1.tar.xz"
  sha256 "b80e2874157cd55071f1b6710fa0b911d5ac5de106a9ee2a4c9c7bee61782f8e"
  license "LGPL-2.1-or-later"

  bottle do
    sha256               arm64_sequoia: "3a602d6d04b23f9ea7e3220f9d15f3665df3effb3e23755647ddc37290043851"
    sha256               arm64_sonoma:  "f4dbd6b6633a8e45f1290c90fd6e97a9ee60e2e0553cea6ff174d8c817beee7d"
    sha256               arm64_ventura: "f9907f3da38a5bee59b1a5b8dd794c2fa761595befc27c7f9c1abcda599c6275"
    sha256 cellar: :any, sonoma:        "42ed98bed547bbeae647d95e0b5f0da4a85e7416cb722efbc4a6e9f975c1bdf0"
    sha256 cellar: :any, ventura:       "051b59d9c1a7d2403a8d34628d6c0acad7c25f50e9d25d4756095c998975e128"
    sha256               x86_64_linux:  "c20490896cab94dc36f83a54bb58ccefea822fb311c03de4a5624e34b09c68ed"
  end

  depends_on "cmake" => :build
  depends_on "gettext" => :build
  depends_on "glib" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build

  depends_on "nettle"
  depends_on "libtasn"
  depends_on "p11-kit"
  depends_on "zlib"
  depends_on "brotli"
  depends_on "zstd"

  depends_on "gnutls"
  depends_on "gsettings-desktop-schemas"

  on_macos do
    depends_on "gettext"
  end

  link_overwrite "lib/gio/modules"

  def install
    # NOTE: ipatch, TODO: fix post install step with conflicting linking of files
    # /home/capin/homebrew/Library/Homebrew/brew.rb (Cask::CaskLoader::NullLoader): loading glib-networking
    # /home/capin/homebrew/Library/Homebrew/brew.rb (Formulary::FromTapLoader): loading homebrew/core/glib-networking
    # Error: The `brew link` step did not complete successfully
    # The formula built, but is not symlinked into /home/capin/homebrew
    # Could not symlink bin/gapplication
    # Target /home/capin/homebrew/bin/gapplication
    # already exists. You may want to remove it:
    #   rm '/home/capin/homebrew/bin/gapplication'

    # To force the link and overwrite all conflicting files:
    #   brew link --overwrite glib-networking

    # To list all files that would be deleted:
    #   brew link --overwrite glib-networking --dry-run

    # Possible conflicting files are:
    # /home/capin/homebrew/bin/gapplication
    # /home/capin/homebrew/bin/gdbus
    # /home/capin/homebrew/bin/gdbus-codegen
    # /home/capin/homebrew/bin/gio
    # /home/capin/homebrew/bin/gio-querymodules
    # /home/capin/homebrew/bin/glib-compile-resources
    # /home/capin/homebrew/bin/glib-compile-schemas
    # /home/capin/homebrew/bin/glib-genmarshal
    # /home/capin/homebrew/bin/glib-gettextize
    # /home/capin/homebrew/bin/glib-mkenums
    # /home/capin/homebrew/bin/gobject-query
    # /home/capin/homebrew/bin/gresource
    # /home/capin/homebrew/bin/gsettings
    # /home/capin/homebrew/bin/gtester
    # /home/capin/homebrew/bin/gtester-report
    # /home/capin/homebrew/bin/pcre2grep
    # /home/capin/homebrew/include/ffi-x86_64.h
    # /home/capin/homebrew/include/ffi.h
    # /home/capin/homebrew/include/ffitarget-x86_64.h
    # /home/capin/homebrew/include/ffitarget.h
    # /home/capin/homebrew/Library/Homebrew/brew.rb (Formulary::FromTapLoader): loading homebrew/core/glib-networking
    # Error: Could not symlink include/gio-unix-2.0/gio/gdesktopappinfo.h
    # Target /home/capin/homebrew/include/gio-unix-2.0/gio/gdesktopappinfo.h
    # is a symlink belonging to glib. You can unlink it:
    #   brew unlink glib

    # To force the link and overwrite all conflicting files:
    #   brew link --overwrite glib

    # To list all files that would be deleted:
    #   brew link --overwrite glib --dry-run

    
    # stop gnome.post_install from doing what needs to be done in the post_install step
    # ENV["DESTDIR"] = "/"


    # :/bin:/usr/sbin:/sbin:
    # ENV.remove "PATH", "/usr/bin"
    # paths_to_remove = ["/bin", "/usr/bin", "/usr/sbin", "/sbin"]
    # paths_to_remove.each { |path| ENV.remove "PATH", path }

    # puts "-----------------------------------------------------------------------"
    # puts "PATH=#{ENV["PATH"]}"
    # puts "-----------------------------------------------------------------------"

    cmake_prefix_path = []
    cmake_prefix_path << Formula["gnutls"].opt_prefix
    cmake_prefix_path << Formula["glib"].opt_prefix
    cmake_prefix_path << Formula["gsettings-desktop-schemas"].opt_prefix
    cmake_prefix_path_string = cmake_prefix_path.join(";")
    ENV["CMAKE_PREFIX_PATH"] = "#{cmake_prefix_path_string}"

    args = %W[
      -Dlibproxy=disabled
      -Dopenssl=disabled
      -Dgnome_proxy=disabled
      --prefix=#{prefix}
      --libdir=#{lib}
      --buildtype=release
    ]

    # NO WORK!
    # ENV["PKG_CONFIG_PATH"] = [
    #   Formula["gnutls"].opt_prefix + "/lib/pkgconfig",
    #   Formula["glib"].opt_prefix + "/lib/pkgconfig"
    # ].join(":")

    # ENV["PKG_CONFIG_PATH"] = Formula["gnutls"].opt_prefix

    pkg_config_path = []
    pkg_config_path << Formula["gnutls"].opt_prefix/"lib/pkgconfig"
    pkg_config_path << Formula["glib"].opt_prefix/"lib/pkgconfig"
    pkg_config_path << Formula["gsettings-desktop-schemas"].opt_prefix/"share/pkgconfig"
    pkg_config_path << Formula["nettle"].opt_prefix/"lib/pkgconfig"
    pkg_config_path << Formula["libtasn"].opt_prefix/"lib/pkgconfig"
    pkg_config_path << Formula["libidn2"].opt_prefix/"lib/pkgconfig"
    pkg_config_path << Formula["p11-kit"].opt_prefix/"lib/pkgconfig"
    pkg_config_path << Formula["zlib"].opt_prefix/"lib/pkgconfig"
    pkg_config_path << Formula["brotli"].opt_prefix/"lib/pkgconfig"
    pkg_config_path << Formula["zstd"].opt_prefix/"lib/pkgconfig"
    pkg_config_path_string = pkg_config_path.join(":")
    ENV["PKG_CONFIG_PATH"] = "#{pkg_config_path_string}"

    puts "-----------------------------------------------------------------------"
    puts "PATH=#{ENV["PATH"]}"
    puts "PKG_CONFIG_PATH=#{ENV["PKG_CONFIG_PATH"]}"
    puts "-----------------------------------------------------------------------"

    # ENV["GIO_QUERYMODULES"] = Formula["glib"].opt_bin/"gio-querymodules"

    # system "meson", "setup", "build", *args, *std_meson_args
    system "meson", "setup", "build", *args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  def post_install
    system Formula["glib"].opt_bin/"gio-querymodules", HOMEBREW_PREFIX/"lib/gio/modules"
  end

  test do
    (testpath/"gtls-test.c").write <<~C
      #include <gio/gio.h>
      int main (int argc, char *argv[])
      {
        if (g_tls_backend_supports_tls (g_tls_backend_get_default()))
          return 0;
        else
          return 1;
      }
    C

    # From `pkg-config --cflags --libs gio-2.0`
    flags = [
      "-D_REENTRANT",
      "-I#{HOMEBREW_PREFIX}/include/glib-2.0",
      "-I#{HOMEBREW_PREFIX}/lib/glib-2.0/include",
      "-I#{HOMEBREW_PREFIX}/opt/gettext/include",
      "-L#{HOMEBREW_PREFIX}/lib",
      "-L#{HOMEBREW_PREFIX}/opt/gettext/lib",
      "-lgio-2.0", "-lgobject-2.0", "-lglib-2.0"
    ]

    system ENV.cc, "gtls-test.c", "-o", "gtls-test", *flags
    system "./gtls-test"
  end
end
