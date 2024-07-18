class Trufflehog < Formula
  desc "Find and verify credentials"
  homepage "https://trufflesecurity.com/"
  url "https://github.com/trufflesecurity/trufflehog/archive/refs/tags/v3.80.0.tar.gz"
  sha256 "d4da78dd12d0c06dbfb52748134c5dfd35a7482d3c4487f60c80c7f1099a48b6"
  # upstream license ask, https://github.com/trufflesecurity/trufflehog/issues/1446
  license "AGPL-3.0-only"
  head "https://github.com/trufflesecurity/trufflehog.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "743e5f988ad1d441e211a0fe1d64cfd49592507b8225ef32bb9f337ef45c0abc"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "4e6fd696dd0b2d903fd756d01df0b5aeacd4883f44c3842d70c3e693c549ed65"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "5a52d28a920667103c93ddaf61bc3f250f7cedc1b11ebeef00f29400b95057a5"
    sha256 cellar: :any_skip_relocation, sonoma:         "9e4b3f9c921610df5f2e7b6e94b98c22dae7c5d16f2c690afead130716fa862c"
    sha256 cellar: :any_skip_relocation, ventura:        "055c51d3c123e79c71a0253b3296668a98714bb4e568cacdaa53ed1055705366"
    sha256 cellar: :any_skip_relocation, monterey:       "167939428a7f178d32058da5489f50580795143006a3c3b6bf0be99a8166320f"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "51fc558720b271659e979a707e55f0735fe89b32110cb6b214230d01325a6898"
  end

  depends_on "go" => :build

  def install
    ldflags = "-s -w -X github.com/trufflesecurity/trufflehog/v3/pkg/version.BuildVersion=#{version}"
    system "go", "build", *std_go_args(ldflags:)
  end

  test do
    repo = "https://github.com/trufflesecurity/test_keys"
    output = shell_output("#{bin}/trufflehog git #{repo} --no-update --only-verified 2>&1")
    expected = "{\"chunks\": 0, \"bytes\": 0, \"verified_secrets\": 0, \"unverified_secrets\": 0, \"scan_duration\":"
    assert_match expected, output

    assert_match version.to_s, shell_output("#{bin}/trufflehog --version 2>&1")
  end
end
