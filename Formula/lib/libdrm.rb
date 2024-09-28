class Libdrm < Formula
  # include Language::Python::Virtualenv

  desc "Library for accessing the direct rendering manager"
  homepage "https://dri.freedesktop.org"
  url "https://dri.freedesktop.org/libdrm/libdrm-2.4.123.tar.xz"
  sha256 "a2b98567a149a74b0f50e91e825f9c0315d86e7be9b74394dae8b298caadb79e"
  license "MIT"

  livecheck do
    url "https://dri.freedesktop.org/libdrm/"
    regex(/href=.*?libdrm[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    sha256 x86_64_linux: "e36b7a4f22e082d69516be926064e80db5c805700560da48f9d33292f1f7a59e"
  end

  depends_on "docutils" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "python@3.12" => :build
  depends_on "libpciaccess"
  depends_on :linux

  # resource "meson" do
  #   url "https://files.pythonhosted.org/packages/34/e8/bb0e264882a42f5d5acae869d5980f298ff9c298d844e18fd1ac009ce7e9/meson-1.5.2.tar.gz"
  #   sha256 ""
  # end

  def python3
    "python3.12"
  end

  def install
    # NOTE: ipatch, bld err
    # ModuleNotFoundError: No module named 'mesonbuild'
    # virtualenv_install_with_resources :using => "python@3.12"

    # NO WORK!
    # system "python3", "meson", "setup", "build", "-Dcairo-tests=disabled", "-Dvalgrind=disabled", *std_meson_args

    puts "-----------------------------------------------------------------"
    puts "PYTHONPATH: #{`python3.12 -c 'import site; print(site.getsitepackages()[0])'`}"
    puts "-----------------------------------------------------------------"

    # system "python3", "-c", "import mesonbuild; print('mesonbuild module is available')"
    puts "-----------------------------------------------------------------"

    # TODO: ipatch, why is the below path not found / added
    # TODO: do not hardcode path entries, mk more robust ie. less brittle
    ENV.prepend_path "PYTHONPATH", "/home/capin/homebrew/lib/python3.12/site-packages"

    # system "meson", "setup", "build", "-Dcairo-tests=disabled", "-Dvalgrind=disabled"
    system "meson", "setup", "build", "-Dcairo-tests=disabled", "-Dvalgrind=disabled", *std_meson_args
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <libdrm/drm.h>
      int main(int argc, char* argv[]) {
        struct drm_gem_open open;
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-ldrm"
  end
end
