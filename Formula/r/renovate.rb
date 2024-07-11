require "language/node"

class Renovate < Formula
  desc "Automated dependency updates. Flexible so you don't need to be"
  homepage "https://github.com/renovatebot/renovate"
  url "https://registry.npmjs.org/renovate/-/renovate-37.428.0.tgz"
  sha256 "9050237eb68029272445aab360ffe6b9e7e9b28c5212b2cef6542bf39539d520"
  license "AGPL-3.0-only"

  # There are thousands of renovate releases on npm and the page the `Npm`
  # strategy checks is several MB in size and can time out before the request
  # resolves. This checks the first page of tags on GitHub (to minimize data
  # transfer).
  livecheck do
    url "https://github.com/renovatebot/renovate/tags"
    regex(%r{href=["']?[^"' >]*?/tag/v?(\d+(?:\.\d+)+)["' >]}i)
    strategy :page_match
    throttle 10
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "d919135c4111af9a61a42f1020a8f08bafc958e059c9a6e9eae761837d0d5975"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "d46c214471aeea05f4c3f4c6478ca3855c070c5e1d2a0427288706c438b54dbe"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "e0d5d9d0d397ef7070498dc5970290aedd511c04cbb369656e600de9739a7919"
    sha256 cellar: :any_skip_relocation, sonoma:         "4e321dfccf6847d1759f21c4e6eb0ef08ef9b58eed8c1719aa703ccb1033a6b4"
    sha256 cellar: :any_skip_relocation, ventura:        "2a321cda8fdbb31b06104387cce7c416b26af38f2aefb66a22988626493acc52"
    sha256 cellar: :any_skip_relocation, monterey:       "2d6a58bad70d71cfd18369f8f951a33a37b40489544d36dfd54a89ec6934df04"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "f91db7d0b052018217d4a812767114cfa037723ff1e67ef4148b002b250147c5"
  end

  depends_on "node"

  uses_from_macos "git", since: :monterey

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    assert_match "FATAL: You must configure a GitHub token", shell_output("#{bin}/renovate 2>&1", 1)
  end
end
