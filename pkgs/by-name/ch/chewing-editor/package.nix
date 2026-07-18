{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gtest,
  libchewing,
  pkg-config,
  qt5,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "chewing-editor";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "chewing";
    repo = "chewing-editor";
    tag = finalAttrs.version;
    hash = "sha256-gF3OotO/xb3Dc0YjVwAKIYnuEPIrgjpGR2tdjOBT4aI=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    gtest
    libchewing
    qt5.qtbase
    qt5.qttools
  ];

  doCheck = true;

  meta = {
    description = "Cross platform chewing user phrase editor";

    longDescription = ''
      chewing-editor is a cross platform chewing user phrase editor. It provides a easy way to manage user phrase. With it, user can customize their user phrase to increase input performance.
    '';

    homepage = "https://github.com/chewing/chewing-editor";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ ShamrockLee ];
    platforms = lib.platforms.all;
    mainProgram = "chewing-editor";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
