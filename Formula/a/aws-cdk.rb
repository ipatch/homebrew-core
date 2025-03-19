class AwsCdk < Formula
  desc "AWS Cloud Development Kit - framework for defining AWS infra as code"
  homepage "https://github.com/aws/aws-cdk"
  url "https://registry.npmjs.org/aws-cdk/-/aws-cdk-2.1005.0.tgz"
  sha256 "c704a79ea7735cee7240c365971d5204fad28a0fdc1a8b55383606378821320d"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any_skip_relocation, all: "7bcab0c22ca72d4005354c2efa36104f6fd2734359b0eae853c9b5fb18e02ed7"
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    # `cdk init` cannot be run in a non-empty directory
    mkdir "testapp" do
      shell_output("#{bin}/cdk init app --language=javascript")
      list = shell_output("#{bin}/cdk list")
      cdkversion = shell_output("#{bin}/cdk --version")
      assert_match "TestappStack", list
      assert_match version.to_s, cdkversion
    end
  end
end
