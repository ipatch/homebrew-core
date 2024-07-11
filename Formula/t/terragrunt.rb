class Terragrunt < Formula
  desc "Thin wrapper for Terraform e.g. for locking state"
  homepage "https://terragrunt.gruntwork.io/"
  url "https://github.com/gruntwork-io/terragrunt/archive/refs/tags/v0.61.0.tar.gz"
  sha256 "94bc9db6baf9c2f233b962768ebd691488285906f1b4789afc64830ea2ce0d7f"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "6dc266a833eed79816462f761647ed7edc8efeab939f0eb191f3f019825383f3"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "b9caad0dc39b8bcea612a9c13340056e6b57458b356f96b93f7c3fb11ac599cf"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "c8e10a0e09695681cb8f68805b07600414becc4759b56f5b359f1a6af8c78918"
    sha256 cellar: :any_skip_relocation, sonoma:         "34a539e0f106d1a9a6b3eebf09e56b5eb0011b3b5a7ce1ff56950b5931317acf"
    sha256 cellar: :any_skip_relocation, ventura:        "5a95c76d709dd3312c6ae1771d9be239180eaa9f30e41752a956b44c4b8cec83"
    sha256 cellar: :any_skip_relocation, monterey:       "1e25ecf011455b5f93409e9c746586eec4fe10e2902d76c3f684478d0cdd8d23"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "072232d7d4cfcdfc87809b87552a5bc0b274f0c3bf878ec82f8a4dcfeaca42e4"
  end

  depends_on "go" => :build

  conflicts_with "tenv", because: "both install terragrunt binary"
  conflicts_with "tgenv", because: "tgenv symlinks terragrunt binaries"

  def install
    ldflags = %W[
      -s -w
      -X github.com/gruntwork-io/go-commons/version.Version=#{version}
    ]
    system "go", "build", *std_go_args(ldflags:)
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/terragrunt --version")
  end
end
