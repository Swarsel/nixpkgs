{
  lib,
  stdenv,
  fetchFromGitHub,
  qca-qt5,
  qmake,
  qtbase,
}:

stdenv.mkDerivation rec {
  pname = "qoauth";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "ayoy";
    repo = "qoauth";
    rev = "v${version}";
    sha256 = "1b2jdqs526ac635yb2whm049spcsk7almnnr6r5b4yqhq922anw3";
    name = "qoauth-${version}.tar.gz";
  };

  postPatch = ''
    sed -i src/src.pro \
        -e 's/lib64/lib/g' \
        -e '/features.path =/ s|$$\[QMAKE_MKSPECS\]|$$NIX_OUTPUT_DEV/mkspecs|'
  '';

  nativeBuildInputs = [ qmake ];

  buildInputs = [
    qtbase
    qca-qt5
  ];

  env = {
    NIX_CFLAGS_COMPILE = "-I${qca-qt5}/include/Qca-qt5/QtCrypto";
    NIX_LDFLAGS = "-lqca-qt5";
  };

  dontWrapQtApps = true;

  meta = {
    inherit (qtbase.meta) platforms;
    description = "Qt library for OAuth authentication";
    homepage = "https://github.com/ayoy/qoauth";
    license = lib.licenses.lgpl21;
  };
}
