{
  lib,
  stdenv,
  fetchFromGitLab,
  cmake,
  qtbase,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qt-color-widgets";
  version = "2.2.0-unstable-2025-05-26";

  src = fetchFromGitLab {
    owner = "mattbas";
    repo = "qt-color-widgets";
    rev = "8491078434b24cba295b5e41cc0d2a94c7049a5b";
    hash = "sha256-77G1NU7079pvqhQnSTmMdkd2g1R2hoJxn183WcsWq8c=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    qtbase
  ];

  cmakeFlags = [
    "-DQT_VERSION_MAJOR=${lib.versions.major qtbase.version}"
  ];

  dontWrapQtApps = true;

  meta = {
    description = "Qt (C++) widgets to manage color inputs";
    homepage = "https://gitlab.com/mattbas/Qt-Color-Widgets";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ dmkhitaryan ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
