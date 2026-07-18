{
  lib,
  stdenv,
  fetchFromGitHub,
  copyDesktopItems,
  kdePackages,
  makeDesktopItem,
  nix-update-script,
  qt6,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qtalarm";
  version = "3.0.1";

  src = fetchFromGitHub {
    owner = "CountMurphy";
    repo = "QTalarm";
    tag = finalAttrs.version;
    hash = "sha256-IN/XdR8J5uMIAjb1G2kzuLDtO972RLKSy3Ceh9CcHWw=";
  };

  nativeBuildInputs = [
    qt6.wrapQtAppsHook
    qt6.qmake
    copyDesktopItems
  ];

  buildInputs = [
    kdePackages.qtbase
    kdePackages.qtmultimedia
  ];

  installPhase = ''
    runHook preInstall
  ''
  + (
    if stdenv.hostPlatform.isDarwin then
      ''
        mkdir -p $out/Applications
        mv qtalarm.app $out/Applications
      ''
    else
      ''
        install -Dm755 qtalarm -t $out/bin
        install -Dm644 Icons/1349069370_Alarm_Clock.png $out/share/icons/hicolor/48x48/apps/qtalarm.png
        install -Dm644 Icons/1349069370_Alarm_Clock24.png $out/share/icons/hicolor/24x24/apps/qtalarm.png
        install -Dm644 Icons/1349069370_Alarm_Clock16.png $out/share/icons/hicolor/16x16/apps/qtalarm.png
      ''
  )
  + ''
    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Application"
        "Utility"
      ];

      desktopName = "QTalarm";
      exec = "qtalarm";
      genericName = "Nifty alarm clock";
      icon = "qtalarm";
      name = "QTalarm";
      terminal = false;
    })
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Nifty alarm clock written in QT";
    homepage = "https://github.com/CountMurphy/QTalarm";
    changelog = "https://github.com/CountMurphy/QTalarm/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ bot-wxt1221 ];
    platforms = lib.platforms.unix;
    mainProgram = "qtalarm";
  };
})
