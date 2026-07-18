{
  lib,
  stdenv,
  fetchurl,
  copyDesktopItems,
  electron,
  gsettings-desktop-schemas,
  gtk3,
  makeDesktopItem,
  unzip,
  wrapGAppsHook3,
}:
stdenv.mkDerivation rec {
  pname = "inav-configurator";
  version = "9.0.0";

  src = fetchurl {
    url = "https://github.com/iNavFlight/inav-configurator/releases/download/${version}/INAV-Configurator_linux_x64_${version}.zip";
    sha256 = "sha256-n56QE0ZJ2slL0WZbnBl2pEgAUoDMuh467gWt+eRwa9c=";
  };

  nativeBuildInputs = [
    copyDesktopItems
    wrapGAppsHook3
    unzip
  ];

  buildInputs = [
    gsettings-desktop-schemas
    gtk3
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin \
             $out/opt/inav-configurator

    cp -r "." $out/opt/inav-configurator/
    install -m 444 -D $icon $out/share/icons/hicolor/128x128/apps/${pname}.png

    chmod +x $out/opt/inav-configurator/inav-configurator
    makeWrapper ${electron}/bin/electron $out/bin/inav-configurator --add-flags $out/opt/inav-configurator/resources/app

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      comment = "iNavFlight configuration tool";
      desktopName = "iNav Configurator";
      exec = pname;
      genericName = "Flight controller configuration tool";
      icon = pname;
      name = pname;
    })
  ];

  icon = fetchurl {
    sha256 = "1i844dzzc5s5cr4vfpi6k2kdn8jiqq2n6c0fjqvsp4wdidwjahzw";
    url = "https://raw.githubusercontent.com/iNavFlight/inav-configurator/bf3fc89e6df51ecb83a386cd000eebf16859879e/images/inav_icon_128.png";
  };

  unpackCmd = "unzip $src";

  meta = {
    description = "INav flight control system configuration tool";

    longDescription = ''
      A crossplatform configuration tool for the iNav flight control system.
      Various types of aircraft are supported by the tool and by iNav, e.g.
      quadcopters, hexacopters, octocopters and fixed-wing aircraft.
    '';

    homepage = "https://github.com/iNavFlight/inav/wiki";
    license = lib.licenses.gpl3Only;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      tilcreator
      wucke13
    ];

    platforms = lib.platforms.linux;
    mainProgram = "inav-configurator";
  };
}
