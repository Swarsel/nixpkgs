{
  lib,
  fetchFromGitHub,
  mkDerivation,
  poppler,
  qmake,
  qtbase,
  qttools,
}:

mkDerivation rec {
  pname = "lumina-pdf";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "lumina-desktop";
    repo = "lumina-pdf";
    rev = "v${version}";
    sha256 = "08caj4nashp79fbvj94rabn0iaa1hymifqmb782x03nb2vkn38r6";
  };

  postPatch = ''
    sed -i '1i\#include <memory>\' Renderer-poppler.cpp
  '';

  nativeBuildInputs = [
    qmake
    qttools
  ];

  buildInputs = [
    qtbase
    poppler
  ];

  enableParallelBuilding = false;

  qmakeFlags = [
    "CONFIG+=WITH_I18N"
    "LRELEASE=${lib.getDev qttools}/bin/lrelease"
  ];

  sourceRoot = "${src.name}/src-qt5";

  meta = {
    description = "PDF viewer for the Lumina Desktop";
    homepage = "https://github.com/lumina-desktop/lumina-pdf";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.unix;
    mainProgram = "lumina-pdf";
    teams = [ lib.teams.lumina ];
  };
}
