{
  lib,
  stdenv,
  autoPatchelfHook,
  bluez,
  copyDesktopItems,
  fetchzip,
  kdePackages,
  makeDesktopItem,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "obdautodoctor";
  version = "5.1.8";

  src = fetchzip {
    url = "https://cdn2.obdautodoctor.com/release/obd-auto-doctor_${finalAttrs.version}_amd64.tar.gz";
    hash = "sha256-3qht1G2Qi+IhL/x9MMEAwM0exCav5iKtnZXTl6cwx3E=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    kdePackages.wrapQtAppsHook
    copyDesktopItems
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    kdePackages.qtbase
    bluez
  ];

  installPhase = ''
    runHook preInstall

    install -D obdautodoctor $out/bin/obdautodoctor
    install -D obdautodoctor.png $out/share/icons/hicolor/128x128/apps/obdautodoctor.png

    install -D license.txt $out/share/licenses/obdautodoctor/license.txt
    install -D lgpl-3.0.txt $out/share/licenses/obdautodoctor/lgpl-3.0.txt

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Qt"
        "Utility"
      ];

      comment = "OBD Car Diagnostics Software";
      desktopName = "OBD Auto Doctor";
      exec = "obdautodoctor";
      icon = "obdautodoctor";
      name = "obdautodoctor";
      terminal = false;
    })
  ];

  dontBuild = true;

  meta = {
    description = "Diagnose problems, reset the Check Engine Light, and monitor your car's performance with ease";
    homepage = "https://www.obdautodoctor.com/";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [ leoflo ];
    platforms = [ "x86_64-linux" ];
  };
})
