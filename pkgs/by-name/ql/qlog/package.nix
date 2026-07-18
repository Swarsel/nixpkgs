{
  lib,
  stdenv,
  fetchFromGitHub,
  cups,
  hamlib,
  pkg-config,
  qt6,
  qt6Packages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qlog";
  version = "0.48.0";

  src = fetchFromGitHub {
    owner = "foldynl";
    repo = "QLog";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Grsrh+WDobWC+zRFYP3xtfGp0VIyTt6XhTMs0+s9qh4=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    pkg-config
    qt6.qmake
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    hamlib
    qt6.qtbase
    qt6.qtcharts
    qt6.qtserialport
    qt6.qtwebchannel
    qt6.qtwebengine
    qt6Packages.qtkeychain
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    cups
  ];

  env.NIX_LDFLAGS = "-lhamlib";

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p $out/{Applications,bin}
    mv $out/{qlog.app,Applications}
    ln -s $out/Applications/qlog.app/Contents/MacOS/qlog $out/bin/qlog
  '';

  meta = {
    description = "Amateur radio logbook software";
    homepage = "https://github.com/foldynl/QLog";
    license = with lib.licenses; [ gpl3Only ];

    maintainers = with lib.maintainers; [
      oliver-koss
    ];

    platforms = with lib.platforms; unix;
    mainProgram = "qlog";
  };
})
