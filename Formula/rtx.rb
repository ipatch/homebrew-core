class Rtx < Formula
  desc "Polyglot runtime manager (asdf rust clone)"
  homepage "https://github.com/jdxcode/rtx"
  url "https://github.com/jdxcode/rtx/archive/refs/tags/v1.27.0.tar.gz"
  sha256 "7cdd3c3e5a6101d3a74fbce19a57994ecb42c06f6a64cf18c924a814bdf38b14"
  license "MIT"
  head "https://github.com/jdxcode/rtx.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "ea4ee7d3383920031378587a38bb4c9c604f0f9785661a7fd3ef489910744141"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "1319bd837363b5042901e955f4e4b447b4cfd1b1d0990f2a237ceb522ec50c69"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "b64433606f7313994ab81afa60acd0b6183d59ce077bb9d73e209658e81fad4f"
    sha256 cellar: :any_skip_relocation, ventura:        "abd61c97f8850dd7e2265c8f8b5fc788b1d479938290b991769bc61604a25d35"
    sha256 cellar: :any_skip_relocation, monterey:       "603861ab1d7dbca0fa4b781718011877b4dd8d1ff0c6850b2902b10f81fab72f"
    sha256 cellar: :any_skip_relocation, big_sur:        "5be9c5712292c50c0db789a725d73fa2012c664de27c5c93617d07f55aa31fa7"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "db574f5ce34692db3350dfe999f56e3ad6c38d714b457eb52b93a96acef0e02a"
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", "--features=brew", *std_cargo_args
    man1.install "man/man1/rtx.1"
    generate_completions_from_executable(bin/"rtx", "complete", "--shell")
  end

  test do
    system "#{bin}/rtx", "install", "nodejs@18.13.0"
    assert_match "v18.13.0", shell_output("#{bin}/rtx exec nodejs@18.13.0 -- node -v")
  end
end
