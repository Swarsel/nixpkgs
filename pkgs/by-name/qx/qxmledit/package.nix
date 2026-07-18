{
  lib,
  stdenv,
  fetchFromGitHub,
  libGLU,
  libsForQt5,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qxmledit";
  version = "0.9.17";

  src = fetchFromGitHub {
    owner = "lbellonda";
    repo = "qxmledit";
    rev = finalAttrs.version;
    hash = "sha256-UzN5U+aC/uKokSdeUG2zv8+mkaH4ndYZ0sfzkpQ3l1M=";
  };

  outputs = [
    "out"
    "doc"
  ];

  nativeBuildInputs = [ libsForQt5.qmake ];

  buildInputs = [
    libsForQt5.qtbase
    libsForQt5.qtxmlpatterns
    libsForQt5.qtsvg
    libsForQt5.qtscxml
    libGLU
  ];

  preConfigure = ''
    export QXMLEDIT_INST_DATA_DIR="$out/share/data"
    export QXMLEDIT_INST_TRANSLATIONS_DIR="$out/share/i18n"
    export QXMLEDIT_INST_INCLUDE_DIR="$out/include"
    export QXMLEDIT_INST_DIR="$out/bin"
    export QXMLEDIT_INST_LIB_DIR="$out/lib"
    export QXMLEDIT_INST_DOC_DIR="$doc"
  '';

  dontWrapQtApps = true;
  qmakeFlags = [ "CONFIG+=release" ];

  meta = {
    description = "Simple XML editor based on qt libraries";
    homepage = "https://sourceforge.net/projects/qxmledit";
    changelog = "https://github.com/lbellonda/qxmledit/blob/${finalAttrs.version}/NEWS";
    license = lib.licenses.lgpl2;
    platforms = lib.platforms.unix;
    mainProgram = "qxmledit";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
