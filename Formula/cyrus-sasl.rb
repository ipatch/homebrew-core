# NOTE: at one point in time it was required to build dlcompat
# first before building cyrus-sasl as stated on the cyrus-sasl
# website, however this is no longer reuqired.

# RANDOM NOTES:
# shasum -a 256 name-of-your-file | awk '{printf $1}' | pbcopy
# `preflight` is used for casks only

class CyrusSasl < Formula
  desc "Simple Authentication and Security Layer"
  homepage "https://www.cyrusimap.org/sasl/"
  url "https://github.com/cyrusimap/cyrus-sasl.git", :branch => "master"
  head "https://github.com/cyrusimap/cyrus-sasl.git", :branch => "master"
  sha256 "9d0b7cf4e48161d3eadbc8fa61cf1b91abf453bf1aae4001cc36412a35882e00"
  # option "",
  # option "",

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "gettext" => :build

  # -stdlib=libstdc++

  def install
    # FileUtils.cd "#{buildpath}"
    # FileUtils.cd "dlcompat-20010505"

    # args = %W[
    #   -stdlib=libstdc++
    # ]
    # system "", *args

    # ENV.append "CXXFLAGS", "-stdlib=libstdc++"

    # system "make"
    # system "make", "install"
    # FileUtils.cd ".."

    # try and setup dlcompat here first
    # `pwd`

    # %x( cd .. )

    `sh ./autogen.sh`

    args = %W[
      --prefix=#{prefix}
    ]

    system "", *args
    system "make"

    system "make", "install"
  end

  test do
    # system bin/"sasl"
  end
end
