class LlamaCpp < Formula
  desc "LLM inference in C/C++"
  homepage "https://github.com/ggerganov/llama.cpp"
  # CMake uses Git to generate version information.
  url "https://github.com/ggerganov/llama.cpp.git",
      tag:      "b3392",
      revision: "bda62d7999caa8c222b6c354ac1e7c7442508539"
  license "MIT"
  head "https://github.com/ggerganov/llama.cpp.git", branch: "master"

  livecheck do
    url :stable
    regex(/^v?b(\d+(?:\.\d+)*)$/i)
  end

  bottle do
    sha256 cellar: :any,                 arm64_sonoma:   "b59196fedef68347ecbe2f1f17f0d655d8b58a4ca28a715b1214d83c30e2ee88"
    sha256 cellar: :any,                 arm64_ventura:  "38f3761311e47f6289a476901c81cbafe8b033d23e846fdd66a696a7543f6828"
    sha256 cellar: :any,                 arm64_monterey: "7b890bb0db927ffbbd972fb75cf166a996af344b54a019661f9d3d5afe4ef1e9"
    sha256 cellar: :any,                 sonoma:         "292d1e33d88d03b5862bc83b9abd7c6ea74f25097507af98c97b7b3446123ae2"
    sha256 cellar: :any,                 ventura:        "43d8e642866680118391f26132034c3c65001363ed1bfb905c62b978fe502de3"
    sha256 cellar: :any,                 monterey:       "dfd2da84078e81e80eefb959da3ca6bb2d07909df991bb6129e0b487b3987d73"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "a336f0d129284d907614d7848d7ed8ded1e176f943eedd0f4bcc69f15c841447"
  end

  depends_on "cmake" => :build
  uses_from_macos "curl"

  on_linux do
    depends_on "pkg-config" => :build
    depends_on "openblas"
  end

  def install
    args = %W[
      -DBUILD_SHARED_LIBS=ON
      -DLLAMA_LTO=ON
      -DLLAMA_CCACHE=OFF
      -DLLAMA_ALL_WARNINGS=OFF
      -DLLAMA_NATIVE=#{build.bottle? ? "OFF" : "ON"}
      -DLLAMA_ACCELLERATE=#{OS.mac? ? "ON" : "OFF"}
      -DLLAMA_BLAS=#{OS.linux? ? "ON" : "OFF"}
      -DLLAMA_BLAS_VENDOR=OpenBLAS
      -DLLAMA_METAL=#{OS.mac? ? "ON" : "OFF"}
      -DLLAMA_METAL_EMBED_LIBRARY=ON
      -DLLAMA_CURL=ON
      -DCMAKE_INSTALL_RPATH=#{rpath}
    ]
    args << "-DLLAMA_METAL_MACOSX_VERSION_MIN=#{MacOS.version}" if OS.mac?

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    libexec.install bin.children
    bin.install_symlink libexec.children.select { |file|
                          file.executable? && !file.basename.to_s.start_with?("test-")
                        }
  end

  test do
    system bin/"llama-cli", "--hf-repo", "ggml-org/tiny-llamas",
                            "-m", "stories260K.gguf",
                            "-n", "400", "-p", "I", "-ngl", "0"
  end
end
