{
  lib,
  stdenv,
  fetchFromGitHub,
  bzip2,
  curl,
  fribidi,
  gtk3,
  iconv,
  libcpuid,
  libjpeg,
  libpng,
  libwebp,
  libxml2,
  pkg-config,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "smooth";
  version = "0.9.10";

  src = fetchFromGitHub {
    owner = "enzo1982";
    repo = "smooth";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-J2Do1iAbE1GBC8co/4nxOzeGJQiPRc+21fgMDpzKX+A=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    bzip2
    curl
    fribidi
    gtk3
    iconv
    libcpuid
    libjpeg
    libpng
    libwebp
    libxml2
    zlib
  ];

  makeFlags = [
    "prefix=$(out)"
    "config=systemlibbz2,systemlibcpuid,systemlibcurl,systemlibfribidi,systemlibiconv,systemlibjpeg,systemlibpng,systemlibwebp,systemlibxml2,systemzlib"
  ];

  meta = {
    description = "Object-oriented class library for C++ application development";
    homepage = "http://www.smooth-project.org/";
    license = lib.licenses.artistic2;
    platforms = lib.platforms.linux;
    mainProgram = "smooth-translator";
  };
})
