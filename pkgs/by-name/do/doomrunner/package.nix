{
  lib,
  stdenv,
  fetchFromGitHub,
  minizip,
  nix-update-script,
  qt6,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "doomrunner";
  version = "1.9.2";

  src = fetchFromGitHub {
    owner = "Youda008";
    repo = "DoomRunner";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jEXY0RoSKLE3fpdAygyUahaLRlz4X8Xnq+talZwrSRM=";
  };

  nativeBuildInputs = [
    qt6.qmake
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    minizip
    qt6.qtbase
  ];

  makeFlags = [
    "INSTALL_ROOT=${placeholder "out"}"
  ];

  postInstall =
    lib.optionalString stdenv.hostPlatform.isDarwin ''
      mkdir -p $out/Applications
      mv $out/usr/bin/DoomRunner.app $out/Applications/
    ''
    + lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
      mkdir -p $out/{bin,share/applications,share/icons/hicolor/128x128/apps}
      install -Dm444 $src/Install/XDG/DoomRunner.128x128.png $out/share/icons/hicolor/128x128/apps/DoomRunner.png
      install -Dm444 $src/Install/XDG/DoomRunner.desktop $out/share/applications/DoomRunner.desktop
      install -Dm755 $out/usr/bin/DoomRunner $out/bin/DoomRunner
    ''
    + ''
      rm -rf $out/usr
    '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Preset-oriented graphical launcher of various ported Doom engines";
    homepage = "https://github.com/Youda008/DoomRunner";
    changelog = "https://github.com/Youda008/DoomRunner/blob/${finalAttrs.src.rev}/changelog.txt";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ keenanweaver ];
    platforms = lib.platforms.all;
    mainProgram = "DoomRunner";
  };
})
