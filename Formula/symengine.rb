class Symengine < Formula
  desc "Fast symbolic manipulation library written in C++"
  homepage "https://sympy.org"
  # TODO: Check if we can use unversioned `llvm` at version bump.
  url "https://github.com/symengine/symengine/releases/download/v0.9.0/symengine-0.9.0.tar.gz"
  sha256 "dcf174ac708ed2acea46691f6e78b9eb946d8a2ba62f75e87cf3bf4f0d651724"
  license "MIT"
  revision 3

  bottle do
    sha256 cellar: :any,                 arm64_ventura:  "d03c14ff05183d5bdf901ee4e8f6bd2dac39bccdaaeedcd5f02b4186be746c37"
    sha256 cellar: :any,                 arm64_monterey: "c7b4cb45ce8a7a3ad479630b0e234ce388f69e972ee915aef56b77b94c152bff"
    sha256 cellar: :any,                 arm64_big_sur:  "5f280ee58a2cf7f00511ae3383de1be2753dbc1a8b0994607773c2f7c042866a"
    sha256 cellar: :any,                 ventura:        "925f15a080442d78b4053a9b953270fc171846498b6524750b44f9900113d863"
    sha256 cellar: :any,                 monterey:       "03da9233b6f783eec8e6399a51ed0fb97e37b191609d3b5f31cf7f90ea1e60d0"
    sha256 cellar: :any,                 big_sur:        "cf30940caff9d6a2b49ca50aab93a103a8c5a71a2363b4200d0157d8f6b46d9f"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "db71eb4cb7428180d9d994a81279d1b8ebeacfd12e0b4c35f403379ece47b013"
  end

  depends_on "cmake" => :build
  depends_on "cereal"
  depends_on "flint"
  depends_on "gmp"
  depends_on "libmpc"
  depends_on "llvm@15"
  depends_on "mpfr"

  fails_with gcc: "5"

  # Avoid static linkage with LLVM. The static libraries contain
  # LTOed objects which causes errors with Apple's `ld`.
  # An alternative workaround is to use `lld` with `-fuse-ld=lld`.
  # TODO(carlocab): Upstream a version of this patch.
  patch do
    url "https://gitweb.gentoo.org/repo/gentoo.git/plain/sci-libs/symengine/files/symengine-0.8.1-fix_llvm.patch?id=83ab9587be9f89e667506b861208d613a2f016e5"
    sha256 "c654ea7c4ee44c689433e87f71c7ae78e6c04968e7dfe89be5e4ba4c8c53713b"
  end

  def install
    system "cmake", "-S", ".", "-B", "build",
                    "-DBUILD_SHARED_LIBS=ON",
                    "-DWITH_GMP=ON",
                    "-DWITH_MPFR=ON",
                    "-DWITH_MPC=ON",
                    "-DINTEGER_CLASS=flint",
                    "-DWITH_LLVM=ON",
                    "-DWITH_COTIRE=OFF",
                    "-DLLVM_DIR=#{Formula["llvm@15"].opt_lib}/cmake/llvm",
                    "-DWITH_SYMENGINE_THREAD_SAFE=ON",
                    "-DWITH_SYSTEM_CEREAL=ON",
                    *std_cmake_args

    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <symengine/expression.h>
      using SymEngine::Expression;
      int main() {
        auto x=Expression('x');
        auto ex = x+sqrt(Expression(2))+1;
        auto equality = eq(ex+1, expand(ex));
        return equality == true;
      }
    EOS
    lib_flags = [
      "-L#{Formula["gmp"].opt_lib}", "-lgmp",
      "-L#{Formula["mpfr"].opt_lib}", "-lmpfr",
      "-L#{Formula["flint"].opt_lib}", "-lflint"
    ]
    system ENV.cxx, "test.cpp", "-std=c++11", "-L#{lib}", "-lsymengine", *lib_flags, "-o", "test"

    system "./test"
  end
end
