{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  jasper,
  libexif,
  libjpeg,
  libpng,
  libtiff,
  libwebp,
  libx11,
  libxrandr,
  libxt,
}:

stdenv.mkDerivation rec {
  pname = "xv";
  version = "6.2.0";

  src = fetchFromGitHub {
    owner = "jasper-software";
    repo = "xv";
    rev = "v${version}";
    sha256 = "sha256-LylTpHTifH/n2vAPlLQooVM3Oox2BJ9eoQYx3USQ/No=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    libx11
    libxt
    libpng
    libwebp
    libtiff
    libjpeg
    jasper
    libxrandr
    libexif
  ];

  meta = {
    description = "Classic image viewer and editor for X";
    homepage = "http://www.trilon.com/xv/";

    license = {
      free = false;
      fullName = "XV License";
      url = "https://github.com/jasper-software/xv/blob/main/src/README";
    };

    maintainers = with lib.maintainers; [ galen ];
  };
}
