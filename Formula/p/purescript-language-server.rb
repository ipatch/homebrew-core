class PurescriptLanguageServer < Formula
  desc "Language Server Protocol server for PureScript"
  homepage "https://github.com/nwolverson/purescript-language-server"
  url "https://registry.npmjs.org/purescript-language-server/-/purescript-language-server-0.18.4.tgz"
  sha256 "ff7523d15d2a8093a788a8cf22c8b82ad778315f667cff1086b747465ad11342"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, all: "9c4693906fb4499e3937b39d88d4f696f26fff1d1a85557e495c7307acc6e42e"
  end

  depends_on "node"
  depends_on "purescript"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    require "open3"

    json = <<~JSON
      {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "initialize",
        "params": {
          "rootUri": null,
          "capabilities": {}
        }
      }
    JSON

    Open3.popen3(bin/"purescript-language-server", "--stdio") do |stdin, stdout|
      stdin.write "Content-Length: #{json.size}\r\n\r\n#{json}"
      assert_match(/^Content-Length: \d+/i, stdout.readline)
    end
  end
end
