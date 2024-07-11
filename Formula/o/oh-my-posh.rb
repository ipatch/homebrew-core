class OhMyPosh < Formula
  desc "Prompt theme engine for any shell"
  homepage "https://ohmyposh.dev"
  url "https://github.com/JanDeDobbeleer/oh-my-posh/archive/refs/tags/v21.23.4.tar.gz"
  sha256 "7ed949c37f6ed02962588a5c356b8b464b328fed48f690fed47d2c14ee5304ee"
  license "MIT"
  head "https://github.com/JanDeDobbeleer/oh-my-posh.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "7d831f51a39ee41b2c874128c94363106ea61ccc4f0bca98f56899678f087d33"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "87bf111a6f3a9632b0b80135c1fc764c8d66f203caab74f01f0c41bab40fbc76"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "f23a00c51bd43d9e7d9702ddbc2eaadad851d82f4fd6b0de46fe5c81223dd9b2"
    sha256 cellar: :any_skip_relocation, sonoma:         "e67a438ea7ac1c3be613b68d69b0f2bec9e6273894f4ca430754d2e3621ee485"
    sha256 cellar: :any_skip_relocation, ventura:        "3f4b9694c84f9be934b965550d1476fa1312f1da2b81df68245c9d0f9737a661"
    sha256 cellar: :any_skip_relocation, monterey:       "82ba2d00bb54be68da5ca1b0aa777a169006bc62f0e19e79a688f3e1a2ffa0cc"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "0a288322e3e26418983b84f19078632eb010246072a342aa9cccd77e80c2c464"
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
