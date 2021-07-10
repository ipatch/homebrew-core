class Pyinvoke < Formula
  include Language::Python::Virtualenv

  desc "Pythonic task management & command execution"
  homepage "https://www.pyinvoke.org/"
  url "https://files.pythonhosted.org/packages/37/b3/0b88358ee07789688d17ec7074a656da68ced50a122183187be12928b535/invoke-1.6.0.tar.gz"
  sha256 "374d1e2ecf78981da94bfaf95366216aaec27c2d6a7b7d5818d92da55aa258d3"
  license "BSD-2-Clause"
  head "https://github.com/pyinvoke/invoke.git"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "c1f2ddf912dcc04d8c2d29eb7ec303fc377664c3a6fe3a67ac556e8da34f9535"
    sha256 cellar: :any_skip_relocation, big_sur:       "70f385b068f6f303a29679061c48b6e9adcf6db396bba3680f26d63d065d926c"
    sha256 cellar: :any_skip_relocation, catalina:      "b1b285e271f44c86c60c87a3891a3285f4c269ce4faba18b148bb28a7b7db5b8"
    sha256 cellar: :any_skip_relocation, mojave:        "685969f8e173f38d99e309231dc44be88c2431b6d2eda004e7c05bbf210802cd"
  end

  depends_on "python@3.9"

  def install
    virtualenv_install_with_resources
  end

  test do
    (testpath/"tasks.py").write <<~EOS
      from invoke import run, task

      @task
      def clean(ctx, extra=''):
          patterns = ['foo']
          if extra:
              patterns.append(extra)
          for pattern in patterns:
              run("rm -rf {}".format(pattern))
    EOS
    (testpath/"foo"/"bar").mkpath
    (testpath/"baz").mkpath
    system bin/"invoke", "clean"
    refute_predicate testpath/"foo", :exist?, "\"pyinvoke clean\" should have deleted \"foo\""
    assert_predicate testpath/"baz", :exist?, "pyinvoke should have left \"baz\""
    system bin/"invoke", "clean", "--extra=baz"
    refute_predicate testpath/"foo", :exist?, "\"pyinvoke clean-extra\" should have still deleted \"foo\""
    refute_predicate testpath/"baz", :exist?, "pyinvoke clean-extra should have deleted \"baz\""
  end
end
