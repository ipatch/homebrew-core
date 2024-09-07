class Aom < Formula
  desc "Codec library for encoding and decoding AV1 video streams"
  homepage "https://aomedia.googlesource.com/aom"
  url "https://aomedia.googlesource.com/aom.git",
      tag:      "v3.10.0",
      revision: "c2fe6bf370f7c14fbaf12884b76244a3cfd7c5fc"
  license "BSD-2-Clause"

  bottle do
    sha256 cellar: :any,                 arm64_sonoma:   "64ae34cc94bd038a3c2072757a794b5eb04084a937fba9caf522c8a752454c14"
    sha256 cellar: :any,                 arm64_ventura:  "3c9b27fc4d94f24bde45494301863ee458a04cb8784889b8232b43ae9e56ccde"
    sha256 cellar: :any,                 arm64_monterey: "ab03b82135121d0d4ab152e931756a9d729e0505b4de4c0b05ab0a0c4105d1ed"
    sha256 cellar: :any,                 sonoma:         "4afef28e07f9cc1d2699e7ae07c119c4976426319f45ca793cfcee7f4385913e"
    sha256 cellar: :any,                 ventura:        "50b74c67ec12634418b728d8512319f25faa0a3b1de843493e62dc227ce09f83"
    sha256 cellar: :any,                 monterey:       "18d2b34abcb8f422e92b865d9f19a933cf0404ea60de00223764077132a4657f"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "9c56432707c34c7e475827872031754611aece7ad575c957e5b96f732580778c"
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
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

    system "cmake", "-S", ".", "-B", "brewbuild", *std_cmake_args, *args
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
