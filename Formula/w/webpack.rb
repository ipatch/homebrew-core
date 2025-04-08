require "json"

class Webpack < Formula
  desc "Bundler for JavaScript and friends"
  homepage "https://webpack.js.org/"
  url "https://registry.npmjs.org/webpack/-/webpack-5.99.4.tgz"
  sha256 "e985ef23cda7e361db65fb81aa95f75da604ce7090b1c2ac0068d51c350b5788"
  license "MIT"
  head "https://github.com/webpack/webpack.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "97ff527fca082c883347588e299d71e66ed9f83779951b849616e22f91e856f2"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "97ff527fca082c883347588e299d71e66ed9f83779951b849616e22f91e856f2"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "97ff527fca082c883347588e299d71e66ed9f83779951b849616e22f91e856f2"
    sha256 cellar: :any_skip_relocation, sonoma:        "1ed13e35a35756dfcf9b9c40ae69c7e2cc90cac6760d4e055fa7451fee9ad8ee"
    sha256 cellar: :any_skip_relocation, ventura:       "1ed13e35a35756dfcf9b9c40ae69c7e2cc90cac6760d4e055fa7451fee9ad8ee"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "97ff527fca082c883347588e299d71e66ed9f83779951b849616e22f91e856f2"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "97ff527fca082c883347588e299d71e66ed9f83779951b849616e22f91e856f2"
  end

  depends_on "node"

  resource "webpack-cli" do
    url "https://registry.npmjs.org/webpack-cli/-/webpack-cli-6.0.1.tgz"
    sha256 "f407788079854b0d48fb750da496c59cf00762dce3731520a4b375a377dec183"
  end

  def install
    (buildpath/"node_modules/webpack").install Dir["*"]
    buildpath.install resource("webpack-cli")

    cd buildpath/"node_modules/webpack" do
      system "npm", "install", *std_npm_args(prefix: false), "--force"
    end

    # declare webpack as a bundledDependency of webpack-cli
    pkg_json = JSON.parse(File.read("package.json"))
    pkg_json["dependencies"]["webpack"] = version
    pkg_json["bundleDependencies"] = ["webpack"]
    File.write("package.json", JSON.pretty_generate(pkg_json))

    system "npm", "install", *std_npm_args

    bin.install_symlink libexec.glob("bin/*")
    bin.install_symlink libexec/"bin/webpack-cli" => "webpack"
  end

  test do
    (testpath/"index.js").write <<~JS
      function component() {
        const element = document.createElement('div');
        element.innerHTML = 'Hello webpack';
        return element;
      }

      document.body.appendChild(component());
    JS

    system bin/"webpack", "bundle", "--mode=production", testpath/"index.js"
    assert_match 'const e=document.createElement("div");', (testpath/"dist/main.js").read
  end
end
