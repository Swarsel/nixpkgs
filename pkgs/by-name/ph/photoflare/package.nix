{
  lib,
  stdenv,
  fetchFromGitHub,
  graphicsmagick,
  libsForQt5,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "photoflare";
  version = "1.6.13";

  src = fetchFromGitHub {
    owner = "PhotoFlare";
    repo = "photoflare";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-0eAuof/FBro2IKxkJ6JHauW6C96VTPxy7QtfPVzPFi4=";
  };

  nativeBuildInputs = [
    libsForQt5.qmake
    libsForQt5.wrapQtAppsHook
    libsForQt5.qttools
  ];

  buildInputs = [
    libsForQt5.qtbase
    graphicsmagick
  ];

  env.NIX_CFLAGS_COMPILE = "-I${graphicsmagick}/include/GraphicsMagick";
  qmakeFlags = [ "PREFIX=${placeholder "out"}" ];

  meta = {
    description = "Cross-platform image editor with a powerful features and a very friendly graphical user interface";
    homepage = "https://photoflare.io";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.omgbebebe ];
    platforms = lib.platforms.linux;
    mainProgram = "photoflare";
  };
})
