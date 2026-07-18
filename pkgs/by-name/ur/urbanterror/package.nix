{
  lib,
  stdenv,
  SDL,
  copyDesktopItems,
  curl,
  fetchzip,
  imagemagick,
  libGL,
  libGLU,
  libicns,
  libxxf86vm,
  makeBinaryWrapper,
  makeDesktopItem,
  openal,
}:

let
  version = "4.3.4";

  urbanterror-maps = fetchzip {
    hash = "sha256-C6Gb5PPECAOjQhmkrzkV6dpY/zHVtUj9oq3507o2PUI=";
    name = "urbanterror-maps";

    url = "http://cdn.urbanterror.info/urt/43/releases/zips/UrbanTerror${
      builtins.replaceStrings [ "." ] [ "" ] version
    }_full.zip";
  };

  urbanterror-source = fetchzip {
    hash = "sha256-zF6Tkaj5WYkFU66VwpBFr1P18OJGrGgxnc/jvcvt8hA=";
    name = "urbanterror-source";
    url = "https://github.com/FrozenSand/ioq3-for-UrbanTerror-4/archive/release-${version}.zip";
  };
in
stdenv.mkDerivation {
  inherit version;
  pname = "urbanterror";

  nativeBuildInputs = [
    copyDesktopItems
    imagemagick
    libicns
    makeBinaryWrapper
  ];

  buildInputs = [
    curl
    libGL
    libGLU
    openal
    libxxf86vm
    SDL
  ];

  preConfigure = ''
    cp ${./Makefile.local} ./Makefile.local
  '';

  preInstall = ''
    mkdir -p $out/share/urbanterror
  '';

  postInstall = ''
    icns2png --extract ${urbanterror-maps}/Quake3-UrT.app/Contents/Resources/quake3-urt.icns

    for size in 16 24 32 48 64 128 256 512 1024; do
      mkdir -pv $out/share/icons/hicolor/"$size"x"$size"/apps
      if [ ! -e quake3-urt_"$size"x"$size"x32.png ] ; then
        convert -resize "$size"x"$size" quake3-urt_512x512x32.png quake3-urt_"$size"x"$size"x32.png
      fi
      install -Dm644 quake3-urt_"$size"x"$size"x32.png $out/share/icons/hicolor/"$size"x"$size"/apps/urbanterror.png
    done;

    makeWrapper $out/share/urbanterror/Quake3-UrT.* $out/bin/urbanterror
    makeWrapper $out/share/urbanterror/Quake3-UrT-Ded.* $out/bin/urbanterror-ded

    ln -s ${urbanterror-maps}/q3ut4 $out/share/urbanterror/
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Game"
        "ActionGame"
      ];

      comment = "A multiplayer tactical FPS on top of Quake 3 engine";
      desktopName = "Urban Terror";
      exec = "urbanterror";
      icon = "urbanterror";
      name = "urbanterror";
    })
  ];

  hardeningDisable = [ "format" ];
  installFlags = [ "COPYDIR=$(out)/share/urbanterror" ];
  installTargets = [ "copyfiles" ];
  sourceRoot = "urbanterror-source";

  srcs = [
    urbanterror-maps
    urbanterror-source
  ];

  meta = {
    description = "Multiplayer tactical FPS on top of Quake 3 engine";

    longDescription = ''
      Urban Terror is a free multiplayer first person shooter developed by
      FrozenSand, that (thanks to the ioquake3-code) does not require
      Quake III Arena anymore. Urban Terror can be described as a Hollywood
      tactical shooter; somewhat realism based, but the motto is "fun over
      realism". This results in a very unique, enjoyable and addictive game.
    '';

    homepage = "https://www.urbanterror.info";
    license = lib.licenses.unfreeRedistributable;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "urbanterror";
  };
}
