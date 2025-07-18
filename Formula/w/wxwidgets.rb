class Wxwidgets < Formula
  desc "Cross-platform C++ GUI toolkit"
  homepage "https://www.wxwidgets.org"
  url "https://github.com/wxWidgets/wxWidgets/releases/download/v3.2.8/wxWidgets-3.2.8.tar.bz2"
  sha256 "c74784904109d7229e6894c85cfa068f1106a4a07c144afd78af41f373ee0fe6"
  license "LGPL-2.0-or-later" => { with: "WxWindows-exception-3.1" }
  head "https://github.com/wxWidgets/wxWidgets.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any,                 arm64_sequoia: "5e0aa82886721db8bc109785272271aecbc86b2e44185bacb6c947fd19f6fcc2"
    sha256 cellar: :any,                 arm64_sonoma:  "c8e1a68822e6a854138ed7d17be706a07df64e4a38900b98a6e88a36f785c500"
    sha256 cellar: :any,                 arm64_ventura: "5d9b32b6973e71173101c6b45d1a350f724442088681b5721caa613318805876"
    sha256 cellar: :any,                 sonoma:        "981feac70f9e659e8e45d1b7de4030fcab77ecda3dab2c0d43033e116d24122c"
    sha256 cellar: :any,                 ventura:       "ef48295f3fdc268a6e1ed3daef93017646105dff9bb962f67b567d66830c451c"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "19d1970a8f32864712fa40f2932e943a097ac9752b04f78fdf912a86b3d6bb11"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "40a393ed11e8f3dee0153c52441eec44b185c197a2c2175a7d592105aa0df5b9"
  end

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "llvm" => :build
  depends_on "pkgconf" => :build
  depends_on "jpeg-turbo"
  depends_on "libpng"
  depends_on "libtiff"
  depends_on "pcre2"

  uses_from_macos "expat"
  uses_from_macos "zlib"

  on_linux do
    depends_on "cairo"
    depends_on "fontconfig"
    depends_on "gdk-pixbuf"
    depends_on "glib"
    depends_on "gtk+3"
    depends_on "libsm"
    depends_on "libx11"
    depends_on "libxkbcommon"
    depends_on "libxtst"
    depends_on "libxxf86vm"
    depends_on "mesa"
    depends_on "mesa-glu"
    depends_on "pango"
    depends_on "wayland"
  end

  def install
    # Remove all bundled libraries excluding `nanosvg` which isn't available as formula
    %w[catch pcre].each { |l| rm_r(buildpath/"3rdparty"/l) }
    %w[expat jpeg png tiff zlib].each { |l| rm_r(buildpath/"src"/l) }

    # args = [
    #   "--enable-clipboard",
    #   "--enable-controls",
    #   "--enable-dataviewctrl",
    #   "--enable-display",
    #   "--enable-dnd",
    #   "--enable-graphics_ctx",
    #   "--enable-std_string",
    #   "--enable-svg",
    #   "--enable-unicode",
    #   "--enable-webviewwebkit",
    #   "--with-expat",
    #   "--with-libjpeg",
    #   "--with-libpng",
    #   "--with-libtiff",
    #   "--with-opengl",
    #   "--with-zlib",
    #   "--disable-tests",
    #   "--disable-precomp-headers",
    #   # This is the default option, but be explicit
    #   "--disable-monolithic",
    # ]

    #--------------------------------------------------------------------------
    # ╰─λ cmake \
    #     -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    #     -DCMAKE_FIND_USE_SYSTEM_ENVIRONMENT_PATH=FALSE \
    #     -DCMAKE_FIND_USE_CMAKE_SYSTEM_PATH=FALSE \
    #     -DCMAKE_VERBOSE_MAKEFILE=1 \
    #     -GNinja \
    #     -DCMAKE_MAKE_PROGRAM=$bp/bin/ninja \
    #     -DCMAKE_C_COMPILER=$bp/bin/clang \
    #     -DCMAKE_CXX_COMPILER=$bp/bin/clang++ \
    #     -DGTK3_INCLUDE_DIRS="$bp/opt/gtk+3/include/gtk-3.0;$bp/opt/glib/include/glib-2.0;$bp/opt/glib/lib/glib-2.0/include;$bp/opt/pango/include/pango-1.0;$bp/opt/harfbuzz/include/harfbuzz/;$bp/opt/cairo/include/cairo;$bp/opt/gdk-pixbuf/include/gdk-pixbuf-2.0/;$bp/opt/at-spi2-core/include/atk-1.0/;" \
    #     -DX11_X11_INCLUDE_PATH=$bp/opt/libx11/include \
    #     -DX11_X11_LIB=$bp/opt/libx11/lib \
    #     -DGTK3_LIBRARIES=$bp/opt/gtk+3/lib \
    #     -DPKG_CONFIG_EXECUTABLE=$bp/bin/pkg-config \
    #     -DCMAKE_IGNORE_PATH="/usr/include;/usr/local/include;/usr/src;/usr;/usr/lib64;/usr/lib;" \
    #     -DCMAKE_PREFIX_PATH=\
    # "$bp/opt/libxkbcommon/;$bp/opt/pcre2;$bp/opt/zlib;$bp/opt/expat;$bp/opt/jpeg-turbo;$bp/opt/libpng;$bp/opt/libtiff;$bp/opt/webp;$bp/opt/glib;$bp/opt/libxcb;$bp/opt/mesa;$bp/opt/msgpack;" \
    #     -L \
    #     ../../tarball-release/wxWidgets-3.2.8

    gtk3_inc_dirs = %W[
      #{Formula["gtk+3"].opt_include}/gtk-3.0
      #{Formula["glib"].opt_include}/glib-2.0
      #{Formula["glib"].opt_lib}/glib-2.0/include
      #{Formula["pango"].opt_include}/pang-1.0
      #{Formula["cairo"].opt_include}/cario
      #{Formula["gdk-pixbuf"].opt_include}/gdk-pixbuf-2.0
      #{Formula["harfbuzz"].opt_include}harfbuzz
      #{Formula["at-spi2-core"].opt_include}/atk-1.0
    ]

    gtk3_lib_dir =%W[
      #{Formula["gtk+3"].opt_lib}
    ]

    libx11_inc_dirs = %W[
      #{Formula["libx11"].opt_include}
    ]

    libx11_lib_dir =%W[
      #{Formula["libx11"].opt_lib}
    ]

    cmake_prefix_paths = %W[
      #{Formula["libxkbcommon"].opt_prefix}
      #{Formula["pcre2"].opt_prefix}
      #{Formula["zlib"].opt_prefix}
      #{Formula["expat"].opt_prefix}
      #{Formula["jpeg-turbo"].opt_prefix}
      #{Formula["libpng"].opt_prefix}
      #{Formula["libtiff"].opt_prefix}
      #{Formula["webp"].opt_prefix}
      #{Formula["glib"].opt_prefix}
      #{Formula["libxcb"].opt_prefix}
      #{Formula["mesa"].opt_prefix}
    ]

    mkdir "build" do
      args = %W[
        -DCMAKE_FIND_USE_SYSTEM_ENVIRONMENT_PATH=FALSE
        -DCMAKE_FIND_USE_CMAKE_SYSTEM_PATH=FALSE
        -DCMAKE_VERBOSE_MAKEFILE=1

        -DCMAKE_BUILD_TYPE=RelWithDebInfo
        -GNinja
        -DCMAKE_INSTALL_PREFIX=#{prefix}

        -DCMAKE_MAKE_PROGRAM=#{Formula["ninja"].opt_bin}/ninja
        -DCMAKE_C_COMPILER=#{Formula["llvm"].opt_bin}/clang
        -DCMAKE_CXX_COMPILER=#{Formula["llvm"].opt_bin}/clang++

        -DGTK3_INCLUDE_DIRS=#{gtk3_inc_dirs}
        -DGTK3_LIBRARIES=#{gtk3_lib_dir}

        -DX11_X11_INCLUDE_PATH=#{libx11_inc_dirs}
        -DX11_X11_LIB=#{libx11_lib_dir}

        -DCMAKE_IGNORE_PATH="/usr/include;/usr/local/include;/usr/src;/usr;/usr/lib64;/usr/lib;"

        -DCMAKE_PREFIX_PATH=#{cmake_prefix_paths}

        -DwxBUILD_SHARED=ON
        -DwxBUILD_TESTS=OFF
        -DwxBUILD_SAMPLES=OFF
        -DwxBUILD_PRECOMP=OFF
        -DwxBUILD_MONOLITHIC=OFF
        -DwxBUILD_TOOLKIT=gtk3
        -DwxBUILD_WEBVIEW=ON
        -DwxUSE_LIBJPEG=sys
        -DwxUSE_LIBPNG=sys
        -DwxUSE_LIBTIFF=sys
        -DwxUSE_EXPAT=sys
        -DwxUSE_ZLIB=sys
        -DwxUSE_REGEX=sys

        -L
      ]

      # macOS-specific options
      if OS.mac?
        args << "-DwxUSE_OSX_CARBON=OFF"
        args << "-DwxUSE_OSX_COCOA=ON"
        args << "-DCMAKE_OSX_DEPLOYMENT_TARGET=#{MacOS.version}"
      end

      system "cmake", "..", *args, *std_cmake_args
      system "ninja"
      system "ninja", "install"
    end

    if OS.mac?
      # Set with-macosx-version-min to avoid configure defaulting to 10.5
      # args << "--with-macosx-version-min=#{MacOS.version}"
      # args << "--with-osx_cocoa"
      # args << "--with-libiconv"

      # Work around deprecated Carbon API, see
      # https://github.com/wxWidgets/wxWidgets/issues/24724
      inreplace "src/osx/carbon/dcscreen.cpp", "#if !wxOSX_USE_IPHONE", "#if 0" if MacOS.version >= :sequoia
    end

    # system "./configure", *args, *std_configure_args
    # system "make", "install"

    # wx-config should reference the public prefix, not wxwidgets's keg
    # this ensures that Python software trying to locate wxpython headers
    # using wx-config can find both wxwidgets and wxpython headers,
    # which are linked to the same place
    inreplace bin/"wx-config", prefix, HOMEBREW_PREFIX

    # For consistency with the versioned wxwidgets formulae
    bin.install_symlink bin/"wx-config" => "wx-config-#{version.major_minor}"
    (share/"wx"/version.major_minor).install share/"aclocal", share/"bakefile"
  end

  def caveats
    <<-EOS
    NOTE: ipatch, this is my super hacky version of wxwidgets built with cmake.
    I decided to build wxwidgets with cmake in hopes of building orca-slicer
    using deps provided by homebrew so i could debug an issue with orca-slicer.

    https://docs.wxwidgets.org/3.2/overview_cmake.html
    EOS
  end

  test do
    system bin/"wx-config", "--libs"
  end
end
