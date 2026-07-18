{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  autoPatchelfHook,
  copyDesktopItems,
  gcc-unwrapped,
  gtk3,
  libdrm,
  libgbm,
  libxdamage,
  libxshmfence,
  makeDesktopItem,
  makeWrapper,
  nss,
  pango,
  squashfsTools,
  udev,
  wrapGAppsHook3,
}:

stdenv.mkDerivation rec {
  pname = "bluemail";
  version = "1.140.93";

  # To update, check https://search.apps.ubuntu.com/api/v1/package/bluemail and copy the anon_download_url and version.
  src = fetchurl {
    url = "https://api.snapcraft.io/api/v1/snaps/download/ZVlj0qw0GOFd5JgTfL8kk2Y5eIG1IpiH_178.snap";
    hash = "sha512-xv7fn+VrtrxauejhgEMdTnmnDXb17TwanXZR6Lqfg5N40MbyDu76XQAWRB8xFU/+GdCTmjv47EaOC7SnnOw4EA==";
  };

  postPatch = ''
    rm -rf usr libEGL.so libGLESv2.so libvk_swiftshader.so libvulkan.so.1
  '';

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    makeWrapper
    squashfsTools
    wrapGAppsHook3
  ];

  buildInputs = [
    pango
    gtk3
    alsa-lib
    nss
    libxdamage
    libdrm
    libgbm
    libxshmfence
    udev
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,opt/bluemail}
    mv * $out/opt/bluemail
    ln -s $out/opt/bluemail/bluemail $out/bin/bluemail

    mkdir -p $out/share/icons
    ln -s $out/opt/bluemail/resources/assets/icons/bluemailx-icon.png $out/share/icons/bluemail.png

    runHook postInstall
  '';

  preFixup = ''
    wrapProgram $out/opt/bluemail/bluemail \
      ''${makeWrapperArgs[@]} \
      ''${gappsWrapperArgs[@]}
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Office" ];
      comment = meta.description;
      desktopName = "BlueMail";
      exec = "bluemail";
      genericName = "Email Reader";
      icon = "bluemail";

      mimeTypes = [
        "x-scheme-handler/me.blueone.linux"
        "x-scheme-handler/mailto"
        "x-scheme-handler/bluemail-notif"
      ];

      name = "bluemail";
    })
  ];

  dontBuild = true;
  dontStrip = true;
  dontWrapGApps = true;

  makeWrapperArgs = [
    "--prefix LD_LIBRARY_PATH : ${
      lib.makeLibraryPath [
        gcc-unwrapped.lib
        gtk3
        udev
      ]
    }"
    "--prefix PATH : ${lib.makeBinPath [ stdenv.cc ]}"
  ];

  sourceRoot = "squashfs-root";

  unpackPhase = ''
    runHook preUnpack

    unsquashfs $src

    runHook postUnpack
  '';

  meta = {
    description = "Cross platform email and calendar app, with AI features and a modern design";
    homepage = "https://bluemail.me";
    license = lib.licenses.unfree;
    # Vendored copy of Electron.
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "bluemail";
  };
}
