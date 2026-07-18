{
  lib,
  stdenv,
  fetchurl,
  electron,
  makeDesktopItem,
  makeWrapper,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "stretchly";
  version = "1.19.0";

  src = fetchurl {
    url = "https://github.com/hovancik/stretchly/releases/download/v${finalAttrs.version}/stretchly-${finalAttrs.version}.tar.xz";
    hash = "sha256-llcKbzlqGMxwrqH1qvQo4fHxO0C1itVZ5wlkwL1IOOU=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/stretchly/
    mv resources/app.asar* $out/share/stretchly/

    mkdir -p $out/share/applications
    ln -s ${finalAttrs.desktopItem}/share/applications/* $out/share/applications/

    makeWrapper ${electron}/bin/electron $out/bin/stretchly \
      --add-flags $out/share/stretchly/app.asar

    runHook postInstall
  '';

  desktopItem = makeDesktopItem {
    categories = [ "Utility" ];
    desktopName = "Stretchly";
    exec = "stretchly";
    genericName = "Stretchly";
    icon = finalAttrs.icon;
    name = "stretchly";
  };

  icon = fetchurl {
    hash = "sha256-tO0cNKopG/recQus7KDUTyGpApvR5/tpmF5C4V14DnI=";
    url = "https://raw.githubusercontent.com/hovancik/stretchly/v${finalAttrs.version}/stretchly_128x128.png";
  };

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Break time reminder app";

    longDescription = ''
      stretchly is a cross-platform electron app that reminds you to take
      breaks when working on your computer. By default, it runs in your tray
      and displays a reminder window containing an idea for a microbreak for 20
      seconds every 10 minutes. Every 30 minutes, it displays a window
      containing an idea for a longer 5 minute break.
    '';

    homepage = "https://hovancik.net/stretchly";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ _1000101 ];
    platforms = lib.platforms.linux;
    mainProgram = "stretchly";
    downloadPage = "https://hovancik.net/stretchly/downloads/";
  };
})
