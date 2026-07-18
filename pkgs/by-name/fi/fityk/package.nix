{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  boost186,
  bzip2,
  gnuplot,
  lua,
  readline,
  swig,
  wxwidgets_3_2,
  xylib,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fityk";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "wojdyr";
    repo = "fityk";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-m2RaZMYT6JGwa3sOUVsBIzCdZetTbiygaInQWoJ4m1o=";
  };

  nativeBuildInputs = [
    autoreconfHook
    lua
    swig
  ];

  buildInputs = [
    wxwidgets_3_2
    boost186
    lua
    zlib
    bzip2
    xylib
    readline
    gnuplot
  ];

  configureFlags = [
    "--with-wx-config=${lib.getExe' (lib.getDev wxwidgets_3_2) "wx-config"}"
  ];

  env.NIX_CFLAGS_COMPILE = toString [
    "-std=c++11"
  ];

  meta = {
    description = "Curve fitting and peak fitting software";
    homepage = "https://fityk.nieto.pl/";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
  };
})
