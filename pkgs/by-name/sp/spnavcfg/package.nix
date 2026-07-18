{
  lib,
  stdenv,
  fetchFromGitHub,
  libspnav,
  pkg-config,
  qt6,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "spnavcfg";
  version = "1.3";

  src = fetchFromGitHub {
    owner = "FreeSpacenav";
    repo = "spnavcfg";
    tag = "v${finalAttrs.version}";
    hash = "sha256-HYBb1/SgjayJjdA0N8UHPde3y4SugYiWIPP+3Eu3CEI=";
    fetchLFS = true;
  };

  nativeBuildInputs = [
    pkg-config
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    libspnav
  ];

  configureFlags = [
    "--qt6"
    "--qt-tooldir=${qt6.qtbase}/libexec"
  ];

  meta = {
    description = "Interactive configuration GUI for space navigator input devices";
    homepage = "https://spacenav.sourceforge.net/";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "spnavcfg";
  };
})
