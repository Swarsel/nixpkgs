{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  copyDesktopItems,
  gcc-unwrapped,
  gsettings-desktop-schemas,
  gtk3,
  libGL,
  makeDesktopItem,
  makeWrapper,
  nwjs,
  udev,
  unzip,
  wrapGAppsHook3,
}:

stdenv.mkDerivation rec {
  pname = "popcorntime";
  version = "0.5.1";

  src = fetchurl {
    url = "https://github.com/popcorn-official/popcorn-desktop/releases/download/v${version}/Popcorn-Time-${version}-linux64.zip";
    hash = "sha256-lCsIioR252GWP/+wNwkTw5PLSal/M9x6mlR/EKOd/hs=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    unzip
    wrapGAppsHook3
    copyDesktopItems
  ];

  buildInputs = [
    gcc-unwrapped
    gsettings-desktop-schemas
    gtk3
    nwjs
    udev
  ];

  # Extract and copy executable in $out/bin
  installPhase = ''
    mkdir -p $out/share/applications $out/bin $out/opt/bin $out/share/icons/hicolor/scalable/apps/
    # we can't unzip it in $out/lib, because nw.js will start with
    # an empty screen. Therefore it will be unzipped in a non-typical
    # folder and symlinked.
    unzip -q $src -d $out/opt/popcorntime

    ln -s $out/opt/popcorntime/Popcorn-Time $out/bin/popcorntime

    ln -s $out/opt/popcorntime/src/app/images/icon.png $out/share/icons/hicolor/scalable/apps/popcorntime.png

    ln -s ${desktopItem}/share/applications/popcorntime.desktop $out/share/applications/popcorntime.desktop
  '';

  # GSETTINGS_SCHEMAS_PATH is not set in installPhase
  preFixup = ''
    wrapProgram $out/bin/popcorntime \
      ''${makeWrapperArgs[@]} \
      ''${gappsWrapperArgs[@]}
  '';

  desktopItem = makeDesktopItem {
    categories = [
      "Video"
      "AudioVideo"
    ];

    comment = meta.description;
    desktopName = "Popcorn-Time";
    exec = pname;
    genericName = meta.description;
    icon = pname;
    name = pname;
    type = "Application";
  };

  dontUnpack = true;
  dontWrapGApps = true;

  makeWrapperArgs = [
    "--prefix LD_LIBRARY_PATH : ${
      lib.makeLibraryPath [
        gcc-unwrapped.lib
        gtk3
        udev
        libGL
      ]
    }"
    "--prefix PATH : ${lib.makeBinPath [ stdenv.cc ]}"
  ];

  sourceRoot = ".";

  meta = {
    description = "Application that streams movies and TV shows from torrents";
    homepage = "https://github.com/popcorn-official/popcorn-desktop";
    license = lib.licenses.gpl3;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ onny ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "popcorntime";
  };
}
