class Pango < Formula
  desc "Framework for layout and rendering of i18n text"
  homepage "https://www.gtk.org/docs/architecture/pango"
  url "https://download.gnome.org/sources/pango/1.56/pango-1.56.1.tar.xz"
  sha256 "426be66460c98b8378573e7f6b0b2ab450f6bb6d2ec7cecc33ae81178f246480"
  license "LGPL-2.0-or-later"
  head "https://gitlab.gnome.org/GNOME/pango.git", branch: "main"

  # Pango doesn't follow GNOME's "even-numbered minor is stable" version
  # scheme but they do appear to use 90+ minor/patch versions, which may
  # indicate unstable versions (e.g., 1.90, etc.).
  livecheck do
    url "https://download.gnome.org/sources/pango/cache.json"
    regex(/pango[._-]v?(\d+(?:(?!\.9\d)\.\d+)+)\.t/i)
  end

  bottle do
    sha256 cellar: :any, arm64_sequoia: "48507210c600d918ab097c8be972714d2d221ec7d57590aa01a7543dd73ff96d"
    sha256 cellar: :any, arm64_sonoma:  "10d30603c08a15d21c900460daed6d3393c7b3f11a1efcfaa95dfbc045023f30"
    sha256 cellar: :any, arm64_ventura: "4cfd2e2270153041accfa3058a3775be97269cd8c25714108ef31bd1713ffd3a"
    sha256 cellar: :any, sonoma:        "b8f0e79a0f83ea4217c6cf8c99cc1162e4c1b53e35ef07e0716f1046e05b2e2a"
    sha256 cellar: :any, ventura:       "092ccfa014c748aa3b6c29fbbe55ab05b59615ad169fafd52339533b06adb2e5"
    sha256               x86_64_linux:  "afb0dbe85b9754c5daddb614add5e0092dbfec27a3e0fc88ab1cb71a6623ed23"
  end

  depends_on "gobject-introspection" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => [:build, :test]
  depends_on "cairo"
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "fribidi"
  depends_on "glib"
  depends_on "harfbuzz"

  def install
    # NOTE: ipatch, bld err, Dependency glib-2.0 found: YES 2.82.4 (cached)
    # Program /home/capin/homebrew/Cellar/glib/2.82.4/bin/glib-mkenums found: YES (/home/capin/homebrew/Cellar/glib/2.82.4/bin/glib-mkenums)
    # Dependency glib-2.0 found: YES 2.82.4 (cached)
    # Program /home/capin/homebrew/Cellar/glib/2.82.4/bin/glib-mkenums found: YES (/home/capin/homebrew/Cellar/glib/2.82.4/bin/glib-mkenums)
    # ----
    # CKS '-DG_LOG_DOMAIN="Pango"' -DG_LOG_USE_STRUCTURED=1 -DPANGO_COMPILATION '-DSYSCONFDIR="/home/capin/homebrew/Cellar/pango/1.56.1/etc"' '-DLIBDIR="/home/capin/homebrew/Cellar/pango/1.56.1/lib"' -MD -MQ pango/libpango-1.0.so.0.5600.1.p/fonts.c.o -MF pango/libpango-1.0.so.0.5600.1.p/fonts.c.o.d -o pango/libpango-1.0.so.0.5600.1.p/fonts.c.o -c ../pango/fonts.c
    # In file included from /home/capin/homebrew/Cellar/glib/2.82.4/include/glib-2.0/glib/gtypes.h:36,
    #                 from /home/capin/homebrew/Cellar/glib/2.82.4/include/glib-2.0/glib/galloca.h:34,
    #                 from /home/capin/homebrew/Cellar/glib/2.82.4/include/glib-2.0/glib.h:32,
    #                 from /home/capin/homebrew/Cellar/glib/2.82.4/include/glib-2.0/gobject/gbinding.h:30,
    #                 from /home/capin/homebrew/Cellar/glib/2.82.4/include/glib-2.0/glib-object.h:24,
    #                 from /home/capin/homebrew/Cellar/glib/2.82.4/include/glib-2.0/gio/gioenums.h:30,
    #                 from /home/capin/homebrew/Cellar/glib/2.82.4/include/glib-2.0/gio/giotypes.h:30,
    #                 from /home/capin/homebrew/Cellar/glib/2.82.4/include/glib-2.0/gio/gio.h:28,
    #                 from ../pango/fonts.c:28:
    # /home/capin/homebrew/Cellar/glib/2.82.4/include/glib-2.0/glib/gversionmacros.h:381:2: error: #error "GLIB_VERSION_MIN_REQUIRED must be <= GLIB_VERSION_CUR_STABLE"
    #   381 | #error "GLIB_VERSION_MIN_REQUIRED must be <= GLIB_VERSION_CUR_STABLE"
    #       |  ^~~~~
    # /home/capin/homebrew/Cellar/glib/2.82.4/include/glib-2.0/glib/gversionmacros.h:384:2: error: #error "GLIB_VERSION_MAX_ALLOWED must be >= GLIB_VERSION_MIN_REQUIRED"
    #   384 | #error "GLIB_VERSION_MAX_ALLOWED must be >= GLIB_VERSION_MIN_REQUIRED"
    #       |  ^~~~~
    # ninja: build stopped: subcommand failed.
    # INFO: autodetecting backend as ninja

    args = %w[
      -Ddefault_library=both
      -Dintrospection=enabled
      -Dfontconfig=enabled
      -Dcairo=enabled
      -Dfreetype=enabled
    ]
    # NO WORK!
      # -Dglib=2.82.4

    # NOTE: tshoot
    # system "meson", "setup", "build"
    # system "meson", "configure", "build"

    system "meson", "setup", "build", *args, *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  test do
    system bin/"pango-view", "--version"
    (testpath/"test.c").write <<~C
      #include <pango/pangocairo.h>

      int main(int argc, char *argv[]) {
        PangoFontMap *fontmap;
        int n_families;
        PangoFontFamily **families;
        fontmap = pango_cairo_font_map_get_default();
        pango_font_map_list_families (fontmap, &families, &n_families);
        g_free(families);
        return 0;
      }
    C

    flags = shell_output("pkgconf --cflags --libs pangocairo").chomp.split
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
  end
end
