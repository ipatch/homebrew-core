class Netpbm < Formula
  desc "Image manipulation"
  homepage "https://netpbm.sourceforge.net/"
  # Maintainers: Look at https://sourceforge.net/p/netpbm/code/HEAD/tree/
  # for stable versions and matching revisions.
  url "https://svn.code.sf.net/p/netpbm/code/stable", revision: "4950"
  version "11.02.11"
  license "GPL-3.0-or-later"
  version_scheme 1
  head "https://svn.code.sf.net/p/netpbm/code/trunk"

  livecheck do
    url "https://sourceforge.net/p/netpbm/code/HEAD/log/?path=/stable"
    regex(/Release\s+v?(\d+(?:\.\d+)+)/i)
    strategy :page_match
  end

  bottle do
    sha256 arm64_sequoia: "bdf9bbf06bf3f356e3a07b66e75b25885485128742bab949955d10e490eaddfc"
    sha256 arm64_sonoma:  "c1a49e6ff031ad726842a467942a257720601ee8e1c706212c42c204355a755e"
    sha256 arm64_ventura: "dbaf3b3bc0c952493e077ce9ebe1f2079faa2ff83e9e44c73e807eae8836e14d"
    sha256 sonoma:        "bed02f2b2101528bba5e9ce7ea8a0f34ce02aab7a034c2575fe1573a864435e0"
    sha256 ventura:       "05af7687ceb593ffb1fc661db38801907067b9954e6e69454f03d2829221e4ea"
    sha256 x86_64_linux:  "dfe5451a97b233d44ec3e2b83c7f4e896188adf175a09502fd19c46b8f3a376e"
  end

  depends_on "jasper"
  depends_on "jpeg-turbo"
  depends_on "libpng"
  depends_on "libtiff"

  uses_from_macos "flex" => :build
  uses_from_macos "libxml2"
  uses_from_macos "zlib"

  conflicts_with "jbigkit", because: "both install `pbm.5` and `pgm.5` files"

  patch :DATA

  def install
    cp "config.mk.in", "config.mk"

    inreplace "config.mk" do |s|
      s.remove_make_var! "CC"
      s.change_make_var! "TIFFLIB", "-ltiff"
      s.change_make_var! "JPEGLIB", "-ljpeg"
      s.change_make_var! "PNGLIB", "-lpng"
      s.change_make_var! "ZLIB", "-lz"
      s.change_make_var! "JASPERLIB", "-ljasper"
      s.change_make_var! "JASPERHDR_DIR", Formula["jasper"].opt_include/"jasper"
      s.gsub! "/usr/local/netpbm/rgb.txt", prefix/"misc/rgb.txt"

      if OS.mac?
        s.change_make_var! "CFLAGS_SHLIB", "-fno-common"
        s.change_make_var! "NETPBMLIBTYPE", "dylib"
        s.change_make_var! "NETPBMLIBSUFFIX", "dylib"
        s.change_make_var! "LDSHLIB", "--shared -o $(SONAME)"
      else
        s.change_make_var! "CFLAGS_SHLIB", "-fPIC"
      end
    end

    ENV.deparallelize

    # NOTE: ipatch, bld err
    # libjasper_compat.c: In function 'pmjas_image_decode':
    # libjasper_compat.c:19:18: error: assignment to 'const char *' ...
    # from incompatible pointer type 'const char **' [-Wincompatible-pointer-types]
    #    19 |         *errorP  = errorP;
    #       |                  ^

    # NOTE: ipatch, CXXABI error
    # ENV["LD_LIBRARY_PATH"] = "#{HOMEBREW_PREFIX}/opt/gcc/lib/gcc/lib64" if Hardware::CPU.arm? && OS.linux?
    ENV.append_to_cflags "-Wno-implicit-function-declaration -Wincompatible-pointer-types"

    # Fix compile with newer Clang
    ENV.append_to_cflags "-Wno-implicit-function-declaration" if DevelopmentTools.clang_build_version >= 1403

    system "make"
    system "make", "package", "pkgdir=#{buildpath}/stage"

    cd "stage" do
      inreplace "pkgconfig_template" do |s|
        s.gsub! "@VERSION@", File.read("VERSION").sub("Netpbm ", "").chomp
        s.gsub! "@LINKDIR@", lib
        s.gsub! "@INCLUDEDIR@", include
      end

      prefix.install %w[bin include lib misc]
      lib.install buildpath.glob("staticlink/*.a"), buildpath.glob("sharedlink/#{shared_library("*")}")
      (lib/"pkgconfig").install "pkgconfig_template" => "netpbm.pc"
    end

    # We don't run `make install`, so an unversioned library symlink is never generated.
    # FIXME: Check whether we can call `make install` instead of creating this manually.
    libnetpbm = lib.glob(shared_library("libnetpbm", "*")).reject(&:symlink?).first.basename
    lib.install_symlink libnetpbm => shared_library("libnetpbm")
  end

  test do
    fwrite = shell_output("#{bin}/pngtopam #{test_fixtures("test.png")} -alphapam")
    (testpath/"test.pam").write fwrite
    system bin/"pamdice", "test.pam", "-outstem", testpath/"testing"
    assert_predicate testpath/"testing_0_0.pam", :exist?
    (testpath/"test.xpm").write <<~EOS
      /* XPM */
      static char * favicon_xpm[] = {
      "16 16 4 1",
      " 	c white",
      ".	c blue",
      "X	c black",
      "o	c red",
      "                ",
      "                ",
      "                ",
      "                ",
      "  ....    ....  ",
      " .    .  .    . ",
      ".  ..  ..  ..  .",
      "  .  . .. .  .  ",
      " .   XXXXXX   . ",
      " .   XXXXXX   . ",
      "oooooooooooooooo",
      "oooooooooooooooo",
      "oooooooooooooooo",
      "oooooooooooooooo",
      "XXXXXXXXXXXXXXXX",
      "XXXXXXXXXXXXXXXX"};
    EOS
    ppmout = shell_output("#{bin}/xpmtoppm test.xpm")
    refute_predicate ppmout, :empty?
  end
end

__END__
diff --git a/converter/other/jpeg2000/libjasper_compat.c b/converter/other/jpeg2000/libjasper_compat.c
index <old-index>..<new-index> 100644
--- a/converter/other/jpeg2000/libjasper_compat.c
+++ b/converter/other/jpeg2000/libjasper_compat.c
@@ -16,7 +16,7 @@

     if (jasperP) {
         *imagePP = jasperP;
-        *errorP  = errorP;
+        *errorP  = NULL;  // Indicate no error if successful
     } else {
         pm_asprintf(errorP, "Failed.  Details may have been written to "
                     "Standard Error");
