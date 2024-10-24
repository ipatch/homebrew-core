class Ktlint < Formula
  desc "Anti-bikeshedding Kotlin linter with built-in formatter"
  homepage "https://ktlint.github.io/"
  url "https://github.com/pinterest/ktlint/releases/download/1.4.0/ktlint-1.4.0.zip"
  sha256 "2c819d9c2b854c09eec60fec9f5c3c55d6654830d936171d61001807213fa632"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, all: "151397944a6853d2f11077ea1ad2b617977d262071438eed3a33faaeadd6ad14"
  end

  depends_on "openjdk"

  def install
    libexec.install "bin/ktlint"
    (libexec/"ktlint").chmod 0755
    (bin/"ktlint").write_env_script libexec/"ktlint", Language::Java.java_home_env
  end

  test do
    (testpath/"Main.kt").write <<~EOS
      fun main( )
    EOS
    (testpath/"Out.kt").write <<~EOS
      fun main()
    EOS
    system bin/"ktlint", "-F", "Main.kt"
    assert_equal shell_output("cat Main.kt"), shell_output("cat Out.kt")
  end
end
