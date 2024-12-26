class JfrogCli < Formula
  desc "Command-line interface for JFrog products"
  homepage "https://www.jfrog.com/confluence/display/CLI/JFrog+CLI"
  url "https://github.com/jfrog/jfrog-cli/archive/refs/tags/v2.72.4.tar.gz"
  sha256 "a2ccdfcc790ec41fbe6dc93117d36569aa30ae566296b37106e27ddc3d23c20d"
  license "Apache-2.0"
  head "https://github.com/jfrog/jfrog-cli.git", branch: "v2"

  # There can be a notable gap between when a version is tagged and a
  # corresponding release is created, so we check the "latest" release instead
  # of the Git tags.
  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "5113fb53609c1df4faac590fc1ede799d7eb49a6514207fa7b94ea37ee31ac2c"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "5113fb53609c1df4faac590fc1ede799d7eb49a6514207fa7b94ea37ee31ac2c"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "5113fb53609c1df4faac590fc1ede799d7eb49a6514207fa7b94ea37ee31ac2c"
    sha256 cellar: :any_skip_relocation, sonoma:        "590db2b90a5b458fbc959007c950bef84436034a1b95e87856394f40534c7e89"
    sha256 cellar: :any_skip_relocation, ventura:       "590db2b90a5b458fbc959007c950bef84436034a1b95e87856394f40534c7e89"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "f3bbf81cea80d57dd5b6eac71c3aa4dbec6517ffe2841df654dbdde47e706dc1"
  end

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w", output: bin/"jf")
    bin.install_symlink "jf" => "jfrog"

    generate_completions_from_executable(bin/"jf", "completion", base_name: "jf")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/jf -v")
    assert_match version.to_s, shell_output("#{bin}/jfrog -v")
    with_env(JFROG_CLI_REPORT_USAGE: "false", CI: "true") do
      assert_match "build name must be provided in order to generate build-info",
        shell_output("#{bin}/jf rt bp --dry-run --url=http://127.0.0.1 2>&1", 1)
    end
  end
end
