class OhMyPosh < Formula
  desc "Prompt theme engine for any shell"
  homepage "https://ohmyposh.dev"
  url "https://github.com/JanDeDobbeleer/oh-my-posh/archive/refs/tags/v21.23.5.tar.gz"
  sha256 "33714a6c746d16521452aa5d45a0da14e0c7df9e29cb995c7dcabb4affbe6780"
  license "MIT"
  head "https://github.com/JanDeDobbeleer/oh-my-posh.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "42663ce8bc7173248c310002b5f3f34e679c3402b4ba3c20d9b41bd47c3ec263"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "8f260413ecc39481119e9367191978e26f8097e39954a38074a4f5717435b137"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "320676e1c79b49b5b029499f871aa9bdca7d639b1f72c6c612bd05a09c057144"
    sha256 cellar: :any_skip_relocation, sonoma:         "322b1c6ec2dd1e0c2fc66b9ed0a8ce0fb220ee6e861bf68006b7486d983668aa"
    sha256 cellar: :any_skip_relocation, ventura:        "33c562c42a0e34f5db2864d7b8d123884560a7b867d25aa6ec486c22d2909c99"
    sha256 cellar: :any_skip_relocation, monterey:       "aa9bf9a615003ef08954df4a389c59d5c27f9213e90e901f167ac802de0f030e"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "5d970c7790dbe94c0e4914644cdd6f017dc096d437af7098dd029fbe4d919751"
  end

  depends_on "go" => :build

  def install
    ldflags = %W[
      -s -w
      -X github.com/jandedobbeleer/oh-my-posh/src/build.Version=#{version}
      -X github.com/jandedobbeleer/oh-my-posh/src/build.Date=#{time.iso8601}
    ]
    cd "src" do
      system "go", "build", *std_go_args(ldflags:)
    end

    prefix.install "themes"
    pkgshare.install_symlink prefix/"themes"
  end

  test do
    assert_match "oh-my-posh", shell_output("#{bin}/oh-my-posh --init --shell bash")
    assert_match version.to_s, shell_output("#{bin}/oh-my-posh --version")
  end
end
