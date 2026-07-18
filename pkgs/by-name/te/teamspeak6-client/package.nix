{
  lib,
  fetchurl,
  alsa-lib,
  at-spi2-atk,
  atk,
  autoPatchelfHook,
  cairo,
  copyDesktopItems,
  cups,
  dbus,
  gcc-unwrapped,
  gdk-pixbuf,
  glib,
  gtk3,
  libGL,
  libdrm,
  libgbm,
  libnotify,
  libpulseaudio,
  libvdpau,
  libx11,
  libxdamage,
  libxfixes,
  libxkbcommon,
  libxscrnsaver,
  libxshmfence,
  libxtst,
  makeDesktopItem,
  makeWrapper,
  nss,
  pipewire,
  stdenvNoCC,
  udev,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "teamspeak6-client";
  version = "6.0.0-beta4.1";

  src = fetchurl {
    url = "https://files.teamspeak-services.com/pre_releases/client/${finalAttrs.version}/teamspeak-client.tar.gz";
    hash = "sha256-7f0VQQLa4Gg7qgXMVfoPYPazPRA9uYeX251j3mHaSLo=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    makeWrapper
  ];

  propagatedBuildInputs = [
    alsa-lib
    at-spi2-atk
    atk
    cairo
    cups.lib
    dbus
    gcc-unwrapped.lib
    gdk-pixbuf
    glib
    gtk3
    libdrm
    libnotify
    libpulseaudio
    libxkbcommon
    libgbm
    libvdpau
    nss
    pipewire
    libx11
    libxscrnsaver
    libxdamage
    libxfixes
    libxshmfence
    libxtst
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/teamspeak6-client $out/share/icons/hicolor/64x64/apps/

    cp -a * $out/share/teamspeak6-client
    cp logo-256.png $out/share/icons/hicolor/64x64/apps/teamspeak6-client.png

    makeWrapper $out/share/teamspeak6-client/TeamSpeak $out/bin/TeamSpeak \
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          gcc-unwrapped.lib
          udev
          libGL
          libpulseaudio
          libvdpau
          pipewire
        ]
      }"

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Audio"
        "AudioVideo"
        "Chat"
        "Network"
      ];

      comment = "TeamSpeak Voice Communication Client";
      desktopName = "TeamSpeak";
      exec = "TeamSpeak";
      icon = "teamspeak6-client";
      name = "TeamSpeak";
      startupWMClass = "teamspeak-client";
    })
  ];

  dontBuild = true;
  dontConfigure = true;
  sourceRoot = ".";
  passthru.updateScript = ./update.sh;

  meta = {
    description = "TeamSpeak voice communication tool (beta version)";
    homepage = "https://teamspeak.com/";
    license = lib.licenses.teamspeak;

    maintainers = with lib.maintainers; [
      drafolin
      gepbird
      jojosch
    ];

    platforms = [ "x86_64-linux" ];
    mainProgram = "TeamSpeak";
  };
})
