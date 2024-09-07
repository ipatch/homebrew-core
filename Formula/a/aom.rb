class Aom < Formula
  desc "Codec library for encoding and decoding AV1 video streams"
  homepage "https://aomedia.googlesource.com/aom"
  url "https://aomedia.googlesource.com/aom.git",
      tag:      "v3.11.0",
      revision: "d6f30ae474dd6c358f26de0a0fc26a0d7340a84c"
  license "BSD-2-Clause"

  bottle do
    sha256 cellar: :any,                 arm64_sequoia: "eab56b62a34fa519427a4388055e3f1abe244aebfaaebbd3e7eeb6a2bf770b87"
    sha256 cellar: :any,                 arm64_sonoma:  "02f671d324c3073b89bc753c96d2bb2e0ea79520c4ebe7354bec355eb9988b46"
    sha256 cellar: :any,                 arm64_ventura: "a6d544883fdf924adca547941499685e5e7340a1b7e6e485e1bbfc1bdbea563c"
    sha256 cellar: :any,                 sonoma:        "14d14953b41129d9c6ec2beb5e5d36b62efa05c3a6af8ef8f8804264c8901204"
    sha256 cellar: :any,                 ventura:       "73666ba2ebee2685d2bcea0af94d9208b8147d35108bb3834bacd41060f23b63"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "32716bca18edf78819253b2cc58279af4e021977de36fe1109dd3dd9c53d9166"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "jpeg-xl"
  depends_on "libvmaf"

  on_intel do
    depends_on "yasm" => :build
  end

  # NOTE: ipatch, bld error
  # [ 46%] Building C object CMakeFiles/aom_av1_common.dir/av1/common/resize.c.o
  # /home/capin/homebrew/Library/Homebrew/shims/linux/super/gcc-14  -I/opt/tmp/homebrew/aom-20240907-2494118-byzn0p -I/opt/tmp/homebrew/aom-20240907-2494118-byzn0p/brewbuild -I/opt/tmp/homebrew/aom-20240907-2494118-byzn0p/apps -I/opt/tmp/homebrew/aom-20240907-2494118-byzn0p/common -I/opt/tmp/homebrew/aom-20240907-2494118-byzn0p/examples -I/opt/tmp/homebrew/aom-20240907-2494118-byzn0p/stats -I/opt/tmp/homebrew/aom-20240907-2494118-byzn0p/third_party/libyuv/include -I/opt/tmp/homebrew/aom-20240907-2494118-byzn0p/third_party/libwebm -O3 -DNDEBUG -std=c99 -Wall -Wdisabled-optimization -Wextra -Wextra-semi -Wextra-semi-stmt -Wfloat-conversion -Wformat=2 -Wimplicit-function-declaration -Wlogical-op -Wmissing-declarations -Wmissing-prototypes -Wpointer-arith -Wshadow -Wshorten-64-to-32 -Wsign-compare -Wstring-conversion -Wtype-limits -Wundef -Wuninitialized -Wunreachable-code-aggressive -Wunused -Wvla -Wstack-usage=100000 -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=0 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -I/home/capin/homebrew/Cellar/libvmaf/3.0.0/include -fPIC -MD -MT CMakeFiles/aom_av1_common.dir/av1/common/resize.c.o -MF CMakeFiles/aom_av1_common.dir/av1/common/resize.c.o.d -o CMakeFiles/aom_av1_common.dir/av1/common/resize.c.o -c /opt/tmp/homebrew/aom-20240907-2494118-byzn0p/av1/common/resize.c
  # during RTL pass: expand
  # In file included from /opt/tmp/homebrew/aom-20240907-2494118-byzn0p/av1/common/arm/highbd_compound_convolve_sve2.c:19:
  # In function 'aom_tbl_s16',
  #     inlined from 'highbd_12_convolve4_4_x' at /opt/tmp/homebrew/aom-20240907-2494118-byzn0p/av1/common/arm/highbd_compound_convolve_sve2.c:177:33,
  #     inlined from 'highbd_12_dist_wtd_convolve_x_4tap_sve2' at /opt/tmp/homebrew/aom-20240907-2494118-byzn0p/av1/common/arm/highbd_compound_convolve_sve2.c:223:23:
  # /opt/tmp/homebrew/aom-20240907-2494118-byzn0p/aom_dsp/arm/aom_neon_sve_bridge.h:53:10: internal compiler error: Segmentation fault
  #    53 |   return svget_neonq_s16(svtbl_s16(svset_neonq_s16(svundef_s16(), s),
  #       |          ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #    54 |                                    svset_neonq_u16(svundef_u16(), tbl)));
  #       |                                    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  # NOTE: ipatch,
  # Warning: Files were found with references to the Homebrew shims directory.
  # The offending files are:
  #   .brew/aom.rb


  def install
    ENV.runtime_cpu_detection

    # Conditional logic for setting compiler flags based on architecture
    if Hardware::CPU.arm?
      # This sets the environment variables for ARM architecture
      ENV.append_to_cflags "-march=native -mtune=cortex-a8"
    end

    # NOTE: ipatch, CXXABI error
    ENV["LD_LIBRARY_PATH"] = "#{HOMEBREW_PREFIX}/opt/gcc/lib/gcc/lib64" if Hardware::CPU.arm? && OS.linux?

    args = [
      "-DCMAKE_INSTALL_RPATH=#{rpath}",
      "-DENABLE_DOCS=off",
      "-DENABLE_EXAMPLES=on",
      "-DENABLE_TESTDATA=off",
      "-DENABLE_TESTS=off",
      "-DENABLE_TOOLS=off",
      "-DBUILD_SHARED_LIBS=on",
      "-DCONFIG_TUNE_VMAF=1",
      "-L",
      "-DENABLE_NEON:BOOL=OFF",
      "-DENABLE_NEON_DOTPROD:BOOL=OFF",
      "-DENABLE_NEON_I8MM:BOOL=OFF",
      "-DENABLE_SVE:BOOL=OFF",
      "-DENABLE_SVE2:BOOL=OFF",
    ]

    system "cmake", "-S", ".", "-B", "brewbuild", *args, *std_cmake_args
    system "cmake", "--build", "brewbuild"
    system "cmake", "--install", "brewbuild"
  end

  test do
    resource "homebrew-bus_qcif_15fps.y4m" do
      url "https://media.xiph.org/video/derf/y4m/bus_qcif_15fps.y4m"
      sha256 "868fc3446d37d0c6959a48b68906486bd64788b2e795f0e29613cbb1fa73480e"
    end

    testpath.install resource("homebrew-bus_qcif_15fps.y4m")

    system bin/"aomenc", "--webm",
                         "--tile-columns=2",
                         "--tile-rows=2",
                         "--cpu-used=8",
                         "--output=bus_qcif_15fps.webm",
                         "bus_qcif_15fps.y4m"

    system bin/"aomdec", "--output=bus_qcif_15fps_decode.y4m",
                         "bus_qcif_15fps.webm"
  end
end
