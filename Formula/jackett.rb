class Jackett < Formula
  desc "API Support for your favorite torrent trackers"
  homepage "https://github.com/Jackett/Jackett"
  url "https://github.com/Jackett/Jackett/archive/refs/tags/v0.20.3671.tar.gz"
  sha256 "e4ffe40b5c1b753cbf8df926eb784a97a63ff25c47c9a235486adb2c8399ad81"
  license "GPL-2.0-only"
  head "https://github.com/Jackett/Jackett.git", branch: "master"

  bottle do
    sha256 cellar: :any,                 arm64_ventura:  "4189f1d6a85ef3087d8a1ddf4acce3e4edab22b3f382bc8a85bc016da8326336"
    sha256 cellar: :any,                 arm64_monterey: "46453ce9890f9543c5ff732296e14240dae6c22ad8f95e46fb540b560b07c548"
    sha256 cellar: :any,                 arm64_big_sur:  "ce02bce29554be0d382110e73cd1306daca9bbe86871106a38e5ed8371699022"
    sha256 cellar: :any,                 ventura:        "01f9820ed57b98f946f4b083df5522e30bb375f693871ca4167a2c7f07efb38f"
    sha256 cellar: :any,                 monterey:       "2b171a8621e3550fa5f40cb72418285f8942ff9507b9f650e02410db4ef1b878"
    sha256 cellar: :any,                 big_sur:        "69c258d493dc626a0ee7906544bad606a803b24433c632c571e4e010cca7490c"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "c87ce607d91e32b4f6ddda24245613639b8e4cd52ab9ebd174c0bd33aa3f58a1"
  end

  depends_on "dotnet@6"

  def install
    dotnet = Formula["dotnet@6"]
    os = OS.mac? ? "osx" : OS.kernel_name.downcase
    arch = Hardware::CPU.intel? ? "x64" : Hardware::CPU.arch.to_s

    args = %W[
      --configuration Release
      --framework net#{dotnet.version.major_minor}
      --output #{libexec}
      --runtime #{os}-#{arch}
      --no-self-contained
    ]
    if build.stable?
      args += %W[
        /p:AssemblyVersion=#{version}
        /p:FileVersion=#{version}
        /p:InformationalVersion=#{version}
        /p:Version=#{version}
      ]
    end

    system "dotnet", "publish", "src/Jackett.Server", *args

    (bin/"jackett").write_env_script libexec/"jackett", "--NoUpdates",
      DOTNET_ROOT: "${DOTNET_ROOT:-#{dotnet.opt_libexec}}"
  end

  service do
    run opt_bin/"jackett"
    keep_alive true
    working_dir libexec
    log_path var/"log/jackett.log"
    error_log_path var/"log/jackett.log"
  end

  test do
    assert_match(/^Jackett v#{Regexp.escape(version)}$/, shell_output("#{bin}/jackett --version 2>&1; true"))

    port = free_port

    pid = fork do
      exec "#{bin}/jackett", "-d", testpath, "-p", port.to_s
    end

    begin
      sleep 10
      assert_match "<title>Jackett</title>", shell_output("curl -b cookiefile -c cookiefile -L --silent http://localhost:#{port}")
    ensure
      Process.kill "TERM", pid
      Process.wait pid
    end
  end
end
