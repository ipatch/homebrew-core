require "language/node"

class NetlifyCli < Formula
  desc "Netlify command-line tool"
  homepage "https://www.netlify.com/docs/cli"
  url "https://registry.npmjs.org/netlify-cli/-/netlify-cli-17.33.1.tgz"
  sha256 "f58a82f9f135d68091511187e153629f6fb4fa99dab0942fb3030ff61491da44"
  license "MIT"
  head "https://github.com/netlify/cli.git", branch: "main"

  bottle do
    sha256                               arm64_sonoma:   "1767e9bd6bc2784a858ad5eba584cf02cee4e4c9cb8e4c6eff42ce3ea9896a80"
    sha256                               arm64_ventura:  "021411bf243b11bd3b9d2113d9788a4a932ffded4d30185aa5448c79f4218a7f"
    sha256                               arm64_monterey: "807acc1832ef997cf04c80d0aaea2fafe2c3891fbc639460a1bd18f9ac4c9267"
    sha256                               sonoma:         "da38100e1e687187d617c4c3bd0c1d76bebf46408c33f7b69ad626226a4e709c"
    sha256                               ventura:        "f6e8e2089db0dad360392724f819390620e6a89acb48f5df949b491df1810c5f"
    sha256                               monterey:       "66611c1ad65a55de4f050df2d2618c66abb33cb5014daac715b422a5b022f7b7"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "83b6341a5f0188b932cb88e1992f7f6a57055632c65d090be0bf2d72333455b7"
  end

  depends_on "node"

  on_linux do
    depends_on "glib"
    depends_on "gmp"
    depends_on "vips"
    depends_on "xsel"
  end

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]

    # Remove incompatible pre-built binaries
    node_modules = libexec/"lib/node_modules/netlify-cli/node_modules"

    if OS.linux?
      (node_modules/"@lmdb/lmdb-linux-x64").glob("*.musl.node").map(&:unlink)
      (node_modules/"@msgpackr-extract/msgpackr-extract-linux-x64").glob("*.musl.node").map(&:unlink)
    end

    clipboardy_fallbacks_dir = node_modules/"clipboardy/fallbacks"
    clipboardy_fallbacks_dir.rmtree # remove pre-built binaries
    if OS.linux?
      linux_dir = clipboardy_fallbacks_dir/"linux"
      linux_dir.mkpath
      # Replace the vendored pre-built xsel with one we build ourselves
      ln_sf (Formula["xsel"].opt_bin/"xsel").relative_path_from(linux_dir), linux_dir
    end

    # Remove incompatible pre-built `bare-fs`/`bare-os` binaries
    os = OS.kernel_name.downcase
    arch = Hardware::CPU.intel? ? "x64" : Hardware::CPU.arch.to_s
    node_modules.glob("{bare-fs,bare-os}/prebuilds/*")
                .each { |dir| dir.rmtree if dir.basename.to_s != "#{os}-#{arch}" }
  end

  test do
    assert_match "Not logged in. Please log in to see site status.", shell_output("#{bin}/netlify status")
  end
end
