{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  qt5,
  tinyxml-2,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "pro-office-calculator";
  version = "1.0.13";

  src = fetchFromGitHub {
    owner = "RobJinman";
    repo = "pro_office_calc";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7cYItmWOBDP/ajanwYnyBZobVny/9HumI7e+rLRn5ew=";
  };

  nativeBuildInputs = [
    cmake
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    qt5.qtbase
    qt5.qtmultimedia
    tinyxml-2
  ];

  meta = {
    description = "Completely normal office calculator";
    homepage = "https://proofficecalculator.com/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ pmiddend ];
    platforms = lib.platforms.linux;
    mainProgram = "procalc";
  };
})
