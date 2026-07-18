{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  at-spi2-core,
  atk,
  autoPatchelfHook,
  cairo,
  copyDesktopItems,
  cups,
  dbus,
  expat,
  gcc-unwrapped,
  gdk-pixbuf,
  glib,
  gtk3-x11,
  libgbm,
  libudev0-shim,
  libuuid,
  libx11,
  libxcb,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxrandr,
  libxrender,
  libxscrnsaver,
  libxtst,
  makeDesktopItem,
  makeWrapper,
  nspr,
  nss,
  pango,
  streamlink,
  wrapGAppsHook3,
}:
let
  basename = "streamlink-twitch-gui";
  runtimeLibs = lib.makeLibraryPath [
    gtk3-x11
    libudev0-shim
  ];
  runtimeBins = lib.makeBinPath [ streamlink ];

in
stdenv.mkDerivation rec {
  pname = "${basename}-bin";
  version = "2.5.3";

  src =
    {
      i686-linux = fetchurl {
        hash = "sha256-y252QhVsRakngdApOHgegMMhs61KTxL9gfPjBjaSKOI=";
        url = "https://github.com/streamlink/${basename}/releases/download/v${version}/${basename}-v${version}-linux32.tar.gz";
      };

      x86_64-linux = fetchurl {
        hash = "sha256-ue5Ehj/dLOIJNJVq0Pd6EbA1hkVPz5m+3chVvEXaH6U=";
        url = "https://github.com/streamlink/${basename}/releases/download/v${version}/${basename}-v${version}-linux64.tar.gz";
      };
    }
    .${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  nativeBuildInputs = [
    at-spi2-core
    atk
    alsa-lib
    autoPatchelfHook
    cairo
    copyDesktopItems
    cups.lib
    dbus.lib
    expat
    gcc-unwrapped
    gdk-pixbuf
    glib
    pango
    gtk3-x11
    libgbm
    nss
    nspr
    libuuid
    libx11
    libxcb
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxrandr
    libxrender
    libxscrnsaver
    libxtst
    makeWrapper
    wrapGAppsHook3
  ];

  buildInputs = [ streamlink ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/{bin,opt/${basename},share}

    # Install all files, remove unnecessary ones
    cp -a . $out/opt/${basename}/
    rm -r $out/opt/${basename}/{{add,remove}-menuitem.sh,credits.html,icons/}
    ln -s $out/opt/${basename}/${basename} $out/bin/
    for res in 16 32 48 64 128 256; do
      install -Dm644 \
        icons/icon-"$res".png \
        $out/share/icons/hicolor/"$res"x"$res"/apps/${basename}.png
    done
    runHook postInstall
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --add-flags "--no-version-check" \
      --prefix LD_LIBRARY_PATH : ${runtimeLibs} \
      --prefix PATH : ${runtimeBins}
    )
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "AudioVideo"
        "Network"
      ];

      desktopName = "Streamlink Twitch GUI";
      exec = basename;
      genericName = meta.description;
      icon = basename;
      name = basename;
    })
  ];

  dontBuild = true;
  dontConfigure = true;

  meta = {
    description = "Twitch.tv browser for Streamlink";
    longDescription = "Browse Twitch.tv and watch streams in your videoplayer of choice";
    homepage = "https://streamlink.github.io/streamlink-twitch-gui/";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];

    platforms = [
      "x86_64-linux"
      "i686-linux"
    ];

    mainProgram = "streamlink-twitch-gui";
    downloadPage = "https://github.com/streamlink/streamlink-twitch-gui/releases";
  };
}
