{
  lib,
  stdenv,
  fetchFromGitHub,
  aria2,
  libkiwix,
  nix-update-script,
  pkg-config,
  qt6,
}:

stdenv.mkDerivation rec {
  pname = "kiwix";
  version = "2.5.1";

  src = fetchFromGitHub {
    owner = "kiwix";
    repo = "kiwix-desktop";
    rev = version;
    hash = "sha256-oF2bXmb6oBXNUj91WtuDTWGrwB5JCuzBtuhfDBHIIKA=";
  };

  patches = [
    ./remove-Werror.patch
  ];

  nativeBuildInputs = [
    qt6.qmake
    pkg-config
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    libkiwix
    qt6.qtbase
    qt6.qtwebengine
    qt6.qtsvg
    qt6.qtimageformats
  ];

  qtWrapperArgs = [
    "--prefix PATH : ${lib.makeBinPath [ aria2 ]}"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Offline reader for Web content";
    homepage = "https://kiwix.org";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ greg ];
    platforms = lib.platforms.linux;
    mainProgram = "kiwix-desktop";
  };
}
