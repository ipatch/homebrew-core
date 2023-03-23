class SpirvLlvmTranslator < Formula
  desc "Tool and a library for bi-directional translation between SPIR-V and LLVM IR"
  homepage "https://github.com/KhronosGroup/SPIRV-LLVM-Translator"
  # TODO: Check if we can use unversioned `llvm` at version bump.
  url "https://github.com/KhronosGroup/SPIRV-LLVM-Translator/archive/refs/tags/v15.0.0.tar.gz"
  sha256 "b1bebd77f72988758c00852e78c2ddc545815a612169a0cb377d021e2f846d88"
  license "Apache-2.0" => { with: "LLVM-exception" }
  revision 1

  bottle do
    sha256 cellar: :any,                 arm64_ventura:  "8375284c22ec1390ef4b531a793b0c98983408c4b848c816be5bca5e796bf7e7"
    sha256 cellar: :any,                 arm64_monterey: "09d09dd2456ed69c811ab5295442fb53f63f228c4aaefaddd64684b6547537a8"
    sha256 cellar: :any,                 arm64_big_sur:  "7d130ffac31962ad5368bf834c3a04e1a774d1f764c540ef6beb7ae2b1cefb2b"
    sha256 cellar: :any,                 ventura:        "404c0423ad8d2e50a2eeabc7fb01105c38df052097a12ef53d74297388de26ef"
    sha256 cellar: :any,                 monterey:       "6d04c2058054c55979cf7d8807e93ddebab495f5f68e55a14ba524d172143c93"
    sha256 cellar: :any,                 big_sur:        "4b06e446e11b82361617d10ef8275a47272fa65ab1337dfbf2422e28dec7cf84"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "4e032267e9b20f01db748cd2b6a3addcf56eb23792657230168899d106540a42"
  end

  depends_on "cmake" => :build
  depends_on "llvm@15"

  # See https://gcc.gnu.org/bugzilla/show_bug.cgi?id=56480
  fails_with gcc: "5"

  def llvm
    deps.map(&:to_formula).find { |f| f.name.match? "^llvm" }
  end

  def install
    system "cmake", "-S", ".", "-B", "build", "-DLLVM_BUILD_TOOLS=ON", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.ll").write <<~EOS
      target datalayout = "e-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024"
      target triple = "spir64-unknown-unknown"

      define spir_kernel void @foo() {
        ret void
      }
    EOS
    system llvm.opt_bin/"llvm-as", "test.ll"
    system bin/"llvm-spirv", "test.bc"
    assert_predicate testpath/"test.spv", :exist?
  end
end
