{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  cmake,
  gitMinimal,
  qt6Packages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lpd8editor";
  version = "0.0.18";

  src = fetchFromGitHub {
    owner = "charlesfleche";
    repo = "lpd8editor";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ru6uyoBWWab/D1YLfJ8qXlFOazSJXQER7jgOgjHYrvc=";
  };

  nativeBuildInputs = [
    cmake
    gitMinimal
    qt6Packages.wrapQtAppsHook
  ];

  buildInputs = [
    qt6Packages.qtbase
    qt6Packages.qtsvg
    qt6Packages.qttools
    alsa-lib
  ];

  meta = {
    description = "Linux editor for the Akai LPD8";
    homepage = "https://github.com/charlesfleche/lpd8editor";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pinpox ];
    platforms = lib.platforms.all;
    mainProgram = "lpd8editor";
  };
})
