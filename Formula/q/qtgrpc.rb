class Qtgrpc < Formula
  desc "Provides support for communicating with gRPC services"
  homepage "https://www.qt.io/"
  url "https://download.qt.io/official_releases/qt/6.9/6.9.3/submodules/qtgrpc-everywhere-src-6.9.3.tar.xz"
  mirror "https://qt.mirror.constant.com/archive/qt/6.9/6.9.3/submodules/qtgrpc-everywhere-src-6.9.3.tar.xz"
  mirror "https://mirrors.ukfast.co.uk/sites/qt.io/archive/qt/6.9/6.9.3/submodules/qtgrpc-everywhere-src-6.9.3.tar.xz"
  sha256 "7963c879cb72d5bebea1724602e6896cdc26e8555d872259f217c6b1130afe02"
  license all_of: [
    "GPL-3.0-only", # QtGrpc
    { any_of: ["LGPL-3.0-only", "GPL-2.0-only", "GPL-3.0-only"] }, # QtProtobuf
    { "GPL-3.0-only" => { with: "Qt-GPL-exception-1.0" } }, # qtgrpcgen; qtprotobufgen
    "BSD-3-Clause", # *.cmake
  ]
  head "https://code.qt.io/qt/qtgrpc.git", branch: "dev"

  livecheck do
    formula "qtbase"
  end

  bottle do
    sha256 cellar: :any,                 arm64_tahoe:   "87c2e77be4bab65bb99e4f573260c65174247381092b99518a2c14f0d8f65769"
    sha256 cellar: :any,                 arm64_sequoia: "233ef57468ad5b651a2d37c8ab975f06d0827a4c11fc12d3dad58761c42d23db"
    sha256 cellar: :any,                 arm64_sonoma:  "5fbd8ba7577a6a7cc06c23b0f1d35423e6871831c108eaccc758945ca67a3b88"
    sha256 cellar: :any,                 sonoma:        "9f0602afced7f21647cf8d548186c9acf92020238ba19084eed864fc30657cbc"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "1aa06fdc8411750fe70d995864f44c43b9df825cddea956ded2309d8f324b230"
  end

  depends_on "cmake" => [:build, :test]
  depends_on "ninja" => :build
  depends_on "pkgconf" => :test

  depends_on "abseil"
  depends_on "protobuf"
  depends_on "qtbase"
  depends_on "qtdeclarative"
  depends_on "qtquick3d"

  depends_on "zlib" if OS.linux?

  def install
    args = ["-DCMAKE_STAGING_PREFIX=#{prefix}"]
    args << "-DQT_NO_APPLE_SDK_AND_XCODE_CHECK=ON" if OS.mac?
    args << "-DCMAKE_IGNORE_PATH=/usr/lib64;/usr/lib;/usr/lib64/cmake;/usr/share/cmake" if OS.linux?
    args << "-DCMAKE_PREFIX_PATH=#{HOMEBREW_PREFIX}/opt/zlib"
    # args << "-DZLIB_DIR=#{HOMEBREW_PREFIX}/opt/zlib"
    args << "-L"
    args << "-DZLIB_ROOT=#{HOMEBREW_PREFIX}/opt/zlib"
    args << "-DCMAKE_PREFIX_PATH=#{HOMEBREW_PREFIX}/opt/zlib;#{HOMEBREW_PREFIX}/opt/protobuf;#{HOMEBREW_PREFIX}/opt/qtbase;#{HOMEBREW_PREFIX}/opt/qtdeclarative;#{HOMEBREW_PREFIX}"

    # TODO: ipatch, check for linux, arm64, and possible asahi
    if OS.linux?
      # TODO: ipatch, use formula prefix instead HOMEBREW_PREFIX
      args << "-DCMAKE_IGNORE_PATH=/usr/lib64;/usr/lib;/usr/lib64/cmake;/usr/share/cmake;/usr/local"
      args << "-DCMAKE_FIND_USE_CMAKE_SYSTEM_PATH=OFF"
      args << "-DCMAKE_FIND_USE_SYSTEM_ENVIRONMENT_PATH=OFF"
      args << "-DQt6Quick_DIR=#{HOMEBREW_PREFIX}/opt/qtdeclarative/lib/cmake/Qt6Quick"
      args << "-DQt6QmlNetwork_DIR=#{HOMEBREW_PREFIX}/opt/qtdeclarative/lib/cmake/Qt6QmlNetwork"
      args << "-DQt6QuickControls2_DIR=#{HOMEBREW_PREFIX}/opt/qtdeclarative/lib/cmake/Qt6QuickControls2"
      args << "-DQt6QuickTest_DIR=#{HOMEBREW_PREFIX}/opt/qtdeclarative/lib/cmake/Qt6QuickTest"
      args << "-DCMAKE_AR=#{HOMEBREW_PREFIX}/opt/gcc/bin/gcc-ar-15"
      args << "-DQT_GENERATE_SBOM=ON"
      args << "-DQT_ADDITIONAL_PACKAGES_PREFIX_PATH=#{HOMEBREW_PREFIX}/opt/qtdeclarative;#{HOMEBREW_PREFIX}/opt/qtsvg;#{HOMEBREW_PREFIX}/opt/qtbase"
    end

    puts "------------------------------------------------------------------"
    puts "homebrew prefix: #{HOMEBREW_PREFIX}"
    puts "------------------------------------------------------------------"

    system "cmake", "-S", ".", "-B", "build", "-G", "Ninja",
                    *args, *std_cmake_args(install_prefix: HOMEBREW_PREFIX, find_framework: "FIRST")
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    # Some config scripts will only find Qt in a "Frameworks" folder
    frameworks.install_symlink lib.glob("*.framework") if OS.mac?
  end

  test do
    (testpath/"CMakeLists.txt").write <<~CMAKE
      cmake_minimum_required(VERSION 4.0)
      project(test VERSION 1.0.0 LANGUAGES CXX)
      find_package(Qt6 COMPONENTS Protobuf Grpc)
      qt_standard_project_setup()
      qt_add_executable(clientguide_client main.cpp)
      qt_add_protobuf(clientguide_client PROTO_FILES clientguide.proto)
      qt_add_grpc(clientguide_client CLIENT PROTO_FILES clientguide.proto)
      target_link_libraries(clientguide_client PRIVATE Qt6::Protobuf Qt6::Grpc)
    CMAKE

    (testpath/"clientguide.proto").write <<~PROTO
      syntax = "proto3";
      package client.guide;
      message Request {
        int64 time = 1;
        sint32 num = 2;
      }
      message Response {
        int64 time = 1;
        sint32 num = 2;
      }
      service ClientGuideService {
        rpc UnaryCall (Request) returns (Response);
        rpc ServerStreaming (Request) returns (stream Response);
        rpc ClientStreaming (stream Request) returns (Response);
        rpc BidirectionalStreaming (stream Request) returns (stream Response);
      }
    PROTO

    (testpath/"main.cpp").write <<~CPP
      #include <memory>
      #include <QGrpcHttp2Channel>
      #include "clientguide.qpb.h"
      #include "clientguide_client.grpc.qpb.h"

      int main(void) {
        auto channel = std::make_shared<QGrpcHttp2Channel>(QUrl("http://localhost:#{free_port}"));
        client::guide::ClientGuideService::Client client;
        client.attachChannel(std::move(channel));
        return 0;
      }
    CPP

    system "cmake", "-S", ".", "-B", "."
    system "cmake", "--build", "."
    system "./clientguide_client"
  end
end
