class Pyside < Formula
  desc "Official Python bindings for Qt"
  homepage "https://wiki.qt.io/Qt_for_Python"
  url "https://download.qt.io/official_releases/QtForPython/pyside6/PySide6-6.10.1-src/pyside-setup-everywhere-src-6.10.1.tar.xz"
  mirror "https://cdimage.debian.org/mirror/qt.io/qtproject/official_releases/QtForPython/pyside6/PySide6-6.10.1-src/pyside-setup-everywhere-src-6.10.1.tar.xz"
  sha256 "fd54f40853d61dfd845dbb40d4f89fbd63df5ed341b3d9a2c77bb5c947a0a838"
  # NOTE: We omit some licenses even though they are in SPDX-License-Identifier or LICENSES/ directory:
  # 1. LicenseRef-Qt-Commercial is removed from "OR" options as non-free
  # 2. GFDL-1.3-no-invariants-only is only used by not installed docs, e.g. sources/{pyside6,shiboken6}/doc
  # 3. BSD-3-Clause is only used by not installed examples, tutorials and build scripts
  # 4. Apache-2.0 is only used by not installed examples
  license all_of: [
    { "GPL-3.0-only" => { with: "Qt-GPL-exception-1.0" } },
    { any_of: ["LGPL-3.0-only", "GPL-2.0-only", "GPL-3.0-only"] },
  ]

  livecheck do
    url "https://download.qt.io/official_releases/QtForPython/pyside6/"
    regex(%r{href=.*?PySide6[._-]v?(\d+(?:\.\d+)+)-src/}i)
  end

  bottle do
    sha256                               arm64_tahoe:   "1358a513844ead84ec174aaedf4512623a01c49d048c0728d61396bda0c6a217"
    sha256                               arm64_sequoia: "4d04a8b0a1adfb04ffd0f6ba596c104005644a734aff2c4745ce3df8ae439d45"
    sha256                               arm64_sonoma:  "45cd389bc6bb4a2d07ed52e978fb5cd6ceb1ed6cdbc6f0addba0ac8a9fda4e17"
    sha256 cellar: :any,                 sonoma:        "d6dec27815c9dd8b43dd715f7df7d46731af5b0e24f1463f3e7486cba99b4e3a"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "20bc08eca5e75d6aa2f85197b4c3ecaf6c314d94736d6284b863c796c351f0a5"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "81a26b9daf3b49d731696ae3ad9bc2433a2a4277e5055765c1f33592fc43db17"
  end

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "python-setuptools" => :build
  depends_on "qtshadertools" => :build
  depends_on xcode: :build
  depends_on "pkgconf" => :test

  depends_on "llvm"
  depends_on "python@3.13" # not yet support for Python 3.14, https://wiki.qt.io/Qt_for_Python#Python_compatibility_matrix
  depends_on "qt3d"
  depends_on "qtbase"
  depends_on "qtcharts"
  depends_on "qtconnectivity"
  depends_on "qtdatavis3d"
  depends_on "qtdeclarative"
  depends_on "qtgraphs"
  depends_on "qthttpserver"
  depends_on "qtlocation"
  depends_on "qtmultimedia"
  depends_on "qtnetworkauth"
  depends_on "qtpositioning"
  depends_on "qtquick3d"
  depends_on "qtremoteobjects"
  depends_on "qtscxml"
  depends_on "qtsensors"
  depends_on "qtserialbus"
  depends_on "qtserialport"
  depends_on "qtspeech"
  depends_on "qtsvg"
  depends_on "qttools"
  depends_on "qtwebchannel"
  depends_on "qtwebsockets"

  uses_from_macos "libxml2"
  uses_from_macos "libxslt"

  on_macos do
    depends_on "qtshadertools"
  end

  on_sonoma :or_newer do
    depends_on "qtwebengine"
    depends_on "qtwebview"
  end

  on_linux do
    depends_on "mesa"

    # TODO: Add dependencies on all Linux when `qtwebengine` is bottled on arm64 Linux
    on_intel do
      depends_on "qtwebengine"
      depends_on "qtwebview"
    end
  end

  def python3
    "python3.13"
  end

  def install
    ENV.append_path "PYTHONPATH", buildpath/"build/sources"

    extra_include_dirs = [Formula["qttools"].opt_include]

    # upstream issue: https://bugreports.qt.io/browse/PYSIDE-1684
    inreplace "sources/pyside6/cmake/Macros/PySideModules.cmake",
              "${shiboken_include_dirs}",
              "${shiboken_include_dirs}:#{extra_include_dirs.join(":")}"

    # Install python scripts into pkgshare rather than bin
    inreplace "sources/pyside-tools/CMakeLists.txt", "DESTINATION bin", "DESTINATION #{pkgshare}"

    # Avoid shim reference
    inreplace "sources/shiboken6/ApiExtractor/CMakeLists.txt", "${CMAKE_CXX_COMPILER}", ENV.cxx

    shiboken6_module = prefix/Language::Python.site_packages(python3)/"shiboken6"

    args = [
      "-DCMAKE_MODULE_LINKER_FLAGS=-Wl,-rpath,#{rpath(source: shiboken6_module)}",
      "-DPython_EXECUTABLE=#{which(python3)}",
      "-DBUILD_TESTS=OFF",
      "-DNO_QT_TOOLS=yes",
      "-DFORCE_LIMITED_API=#{OS.mac? ? "yes" : "no"}",
    ]

    if OS.linux? && Hardware::CPU.arm?
      ENV.prepend_path "CPLUS_INCLUDE_PATH", Formula["mesa"].opt_include
      ENV.prepend_path "C_INCLUDE_PATH", Formula["mesa"].opt_include

      # Add Qt module cmake paths
      qt_formula_to_cmake = {
        "qtpositioning" => ["Qt6Positioning"],
        "qtdeclarative" => ["Qt6Qml", "Qt6Quick", "Qt6QuickWidgets", "Qt6QuickControls2", "Qt6QuickTest"],
        "qtmultimedia" => ["Qt6Multimedia", "Qt6MultimediaWidgets", "Qt6SpatialAudio"],
        "qtsvg" => ["Qt6Svg", "Qt6SvgWidgets"],
        "qtserialport" => ["Qt6SerialPort"],
        "qtsensors" => ["Qt6Sensors"],
        "qtwebchannel" => ["Qt6WebChannel"],
        "qtwebsockets" => ["Qt6WebSockets"],
        "qt3d" => ["Qt63DCore", "Qt63DRender", "Qt63DInput", "Qt63DLogic", "Qt63DAnimation", "Qt63DExtras"],
        "qtcharts" => ["Qt6Charts"],
        "qtdatavis3d" => ["Qt6DataVisualization"],
        "qtscxml" => ["Qt6Scxml", "Qt6StateMachine"],
        "qtremoteobjects" => ["Qt6RemoteObjects"],
        "qtspeech" => ["Qt6TextToSpeech"],
        "qtconnectivity" => ["Qt6Bluetooth", "Qt6Nfc"],
        "qtlocation" => ["Qt6Location"],
        "qthttpserver" => ["Qt6HttpServer"],
        "qtserialbus" => ["Qt6SerialBus"],
        "qtnetworkauth" => ["Qt6NetworkAuth"],
        "qtquick3d" => ["Qt6Quick3D"],
        "qtgraphs" => ["Qt6Graphs", "Qt6GraphsWidgets"],
        "qttools" => ["Qt6Designer", "Qt6Help", "Qt6UiTools"],
      }

      qt_formula_to_cmake.each do |formula_name, cmake_modules|
        cmake_modules.each do |mod|
          cmake_dir = Formula[formula_name].opt_lib/"cmake"/mod
          # args << "-D#{mod}_DIR=#{cmake_dir}" if cmake_dir.exist?
        end
      end

      qt_modules = %w[
        qtpositioning qtdeclarative qtmultimedia qtsvg qtserialport
        qtsensors qtwebchannel qtwebsockets qt3d qtcharts qtdatavis3d
        qtscxml qtremoteobjects qtspeech qtconnectivity qtlocation
        qthttpserver qtserialbus qtnetworkauth qtquick3d qtgraphs qttools
      ]

      # Add Qt module include paths for shiboken/clang
      qt_modules.each do |m|
        ENV.prepend_path "CPLUS_INCLUDE_PATH", Formula[m].opt_include
        ENV.prepend_path "C_INCLUDE_PATH", Formula[m].opt_include
      end

      cmake_prefix = qt_modules.map { |m| Formula[m].opt_prefix }.join(";")
      args << "-DCMAKE_PREFIX_PATH:PATH=#{cmake_prefix}"
      args << "-DQT_ADDITIONAL_PACKAGES_PREFIX_PATH=#{cmake_prefix}"
    end

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  def post_install
    # Fix install layout for 6.10+ (shiboken6/PySide6 should be under include/)
    if (prefix/"shiboken6").exist?
      mkdir_p prefix/"include"
      if (prefix/"shiboken6"/"include").exist?
        # shiboken6/include/* -> include/shiboken6/
        mv prefix/"shiboken6"/"include", prefix/"include"/"shiboken6"
        rmdir prefix/"shiboken6" if (prefix/"shiboken6").children.empty?
      else
        mv prefix/"shiboken6", prefix/"include"/"shiboken6"
      end
    end

    if (prefix/"PySide6").exist?
      mkdir_p prefix/"include"
      if (prefix/"PySide6"/"include").exist?
        # PySide6/include/* -> include/PySide6/
        mv prefix/"PySide6"/"include", prefix/"include"/"PySide6"
        rmdir prefix/"PySide6" if (prefix/"PySide6").children.empty?
      else
        mv prefix/"PySide6", prefix/"include"/"PySide6"
      end
    end

    # Create symlink for pkgconfig compatibility (expects shiboken6/include/)
    ln_sf prefix/"include"/"shiboken6", prefix/"shiboken6" unless (prefix/"shiboken6").exist?
  end

  test do
    system python3, "-c", "import PySide6"
    system python3, "-c", "import shiboken6"

    modules = %w[
      Core
      Gui
      Network
      Positioning
      Quick
      Svg
      Widgets
      Xml
    ]
    modules << "WebEngineCore" if (OS.linux? && Hardware::CPU.intel?) || (OS.mac? && MacOS.version >= :sonoma)
    modules.each { |mod| system python3, "-c", "import PySide6.Qt#{mod}" }

    pyincludes = shell_output("#{python3}-config --includes").chomp.split
    pylib = shell_output("#{python3}-config --ldflags --embed").chomp.split

    if OS.linux?
      pyver = Language::Python.major_minor_version python3
      pylib += %W[
        -Wl,-rpath,#{Formula["python@#{pyver}"].opt_lib}
        -Wl,-rpath,#{lib}
      ]
    end

    (testpath/"test.cpp").write <<~CPP
      #include <shiboken.h>
      int main()
      {
        Py_Initialize();
        Shiboken::AutoDecRef module(Shiboken::Module::import("shiboken6"));
        assert(!module.isNull());
        return 0;
      }
    CPP
    shiboken_flags = shell_output("pkgconf --cflags --libs shiboken6").chomp.split
    system ENV.cxx, "-std=c++17", "test.cpp", *shiboken_flags, *pyincludes, *pylib, "-o", "test"
    system "./test"
  end
end
