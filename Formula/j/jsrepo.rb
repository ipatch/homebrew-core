class Jsrepo < Formula
  desc "Build and distribute your code"
  homepage "https://jsrepo.dev/"
  url "https://registry.npmjs.org/jsrepo/-/jsrepo-1.41.4.tgz"
  sha256 "6cee2db8ad0221e13acd0351d673d38c178cf8decaf28bb56b7423358d7b8d68"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "d46c770fa25f35c142559ba7d0b43b10138e3cd45767609ddc7236e6b39b3d1e"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "d46c770fa25f35c142559ba7d0b43b10138e3cd45767609ddc7236e6b39b3d1e"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "d46c770fa25f35c142559ba7d0b43b10138e3cd45767609ddc7236e6b39b3d1e"
    sha256 cellar: :any_skip_relocation, sonoma:        "2dc2c7f9a69161f381a9ff5be7fd246ad639de91e54229c907ef70870d88de49"
    sha256 cellar: :any_skip_relocation, ventura:       "2dc2c7f9a69161f381a9ff5be7fd246ad639de91e54229c907ef70870d88de49"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "d46c770fa25f35c142559ba7d0b43b10138e3cd45767609ddc7236e6b39b3d1e"
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink libexec.glob("bin/*")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/jsrepo --version")

    system bin/"jsrepo", "build"
    assert_match "\"categories\": []", (testpath/"jsrepo-manifest.json").read
  end
end
