{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  at-spi2-core,
  autoPatchelfHook,
  cairo,
  copyDesktopItems,
  fetchzip,
  gtk3,
  libGL,
  libdrm,
  libgbm,
  libglvnd,
  libpulseaudio,
  libx11,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxfixes,
  libxkbcommon,
  libxrandr,
  makeDesktopItem,
  makeWrapper,
  nss,
  pango,
  patchelf,
  systemd,
  undmg,
  vivaldi-ffmpeg-codecs,
}:
let
  pname = "nextcloud-talk-desktop";
  version = "2.1.1"; # Ensure both hashes (Linux and Darwin) are updated!

  hashes = {
    darwin = "sha256-rp6+bYb3Y8yEXYUY+cuDo7Lw6cq/EUnPjLIqscKeULc=";
    linux = "sha256-s6+p21KLoDvcQz0EgV7WYIwYc9JolZpqkxZ8iIol8Yg=";
  };

  # Only x86_64-linux is supported with Darwin support being universal
  sources = {
    darwin = fetchurl {
      hash = hashes.darwin;
      url = "https://github.com/nextcloud-releases/talk-desktop/releases/download/v${version}/Nextcloud.Talk-macos-universal.dmg";
    };

    # Building from source would require building also building Server and Talk components
    # See https://github.com/nextcloud/talk-desktop?tab=readme-ov-file#%EF%B8%8F-prerequisites
    linux = fetchzip {
      hash = hashes.linux;
      stripRoot = false;
      url = "https://github.com/nextcloud-releases/talk-desktop/releases/download/v${version}/Nextcloud.Talk-linux-x64.zip";
    };
  };

  passthru = {
    inherit hashes; # needed by updateScript
    updateScript = ./update.py;
  };

  meta = {
    description = "Nextcloud Talk Desktop Client";
    homepage = "https://github.com/nextcloud/talk-desktop";
    changelog = "https://github.com/nextcloud/talk-desktop/blob/${version}/CHANGELOG.md";
    license = lib.licenses.agpl3Only;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [ kashw2 ];
    mainProgram = "nextcloud-talk-desktop";
  };

  linux = stdenv.mkDerivation (finalAttrs: {
    inherit pname version passthru;
    src = sources.linux;

    nativeBuildInputs = [
      autoPatchelfHook
      copyDesktopItems
    ];

    buildInputs = [
      nss
      cairo
      alsa-lib
      at-spi2-core
      pango
      libdrm
      libxkbcommon
      gtk3
      vivaldi-ffmpeg-codecs
      libgbm
      libGL
      libglvnd
      libx11
      libxcomposite
      libxdamage
      libxrandr
      libxfixes
      libxcursor
      libpulseaudio
    ];

    preInstall = ''
      mkdir -p $out/bin
      mkdir -p $out/opt

      cp -r $src/* $out/opt/
    '';

    installPhase = ''
      runHook preInstall

      # Link the application in $out/bin away from contents of `preInstall`
      ln -s "$out/opt/Nextcloud Talk-linux-x64/Nextcloud Talk" $out/bin/nextcloud-talk-desktop
      mkdir -p $out/share/icons/hicolor/512x512/apps
      cp $icon $out/share/icons/hicolor/512x512/apps/nextcloud-talk-desktop.png

      runHook postInstall
    '';

    postFixup = ''
      ${lib.getExe patchelf} --add-needed libGL.so.1 --add-needed libEGL.so.1 \
        "$out/opt/Nextcloud Talk-linux-x64/Nextcloud Talk"
    '';

    desktopItems = [
      (makeDesktopItem {
        categories = [ "Chat" ];
        comment = finalAttrs.meta.description;
        desktopName = "Nextcloud Talk";
        exec = finalAttrs.meta.mainProgram;
        icon = "nextcloud-talk-desktop";
        name = "nextcloud-talk-desktop";
        type = "Application";
      })
    ];

    icon = fetchurl {
      hash = "sha256-DteSSuxIs0ukIJrvUO/3Mrh5F2GG5UAVvGRZUuZonkg=";
      url = "https://raw.githubusercontent.com/nextcloud/talk-desktop/refs/tags/v${version}/img/icons/icon.png";
    };

    runtimeDependencies = [
      # Required to launch the application and proceed past the zygote_linux fork() process
      # Fixes `Zygote could not fork`
      systemd

      # Fixes input/output audio device selection
      libpulseaudio
    ];

    meta = meta // {
      platforms = lib.intersectLists lib.platforms.linux lib.platforms.x86_64;
    };
  });

  darwin = stdenv.mkDerivation (finalAttrs: {
    inherit pname version passthru;
    src = sources.darwin;

    nativeBuildInputs = [
      undmg
      makeWrapper
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/{Applications,bin}
      mv Nextcloud\ Talk.app/Contents $out/Applications/

      makeWrapper $out/Applications/Contents/MacOS/Nextcloud\ Talk $out/bin/nextcloud-talk-desktop

      runHook postInstall
    '';

    sourceRoot = ".";

    meta = meta // {
      platforms = lib.platforms.darwin;
    };
  });
in
if stdenv.hostPlatform.isDarwin then darwin else linux
