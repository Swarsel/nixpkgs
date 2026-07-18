{
  lib,
  stdenv,
  fetchurl,
  copyDesktopItems,
  desktopToDarwinBundle,
  imagemagick,
  jre,
  makeBinaryWrapper,
  makeDesktopItem,
  unzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mars-mips";
  version = "4.5";

  src = fetchurl {
    url = "https://courses.missouristate.edu/KenVollmar/MARS/MARS_${
      lib.replaceStrings [ "." ] [ "_" ] finalAttrs.version
    }_Aug2014/Mars${lib.replaceStrings [ "." ] [ "_" ] finalAttrs.version}.jar";

    hash = "sha256-rDQLZ2uitiJGud935i+BrURHvP0ymrU5cWvNCZULcJY=";
  };

  nativeBuildInputs = [
    makeBinaryWrapper
    copyDesktopItems
    unzip
    imagemagick
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    desktopToDarwinBundle
  ];

  installPhase = ''
    runHook preInstall

    export JAR=$out/share/java/mars/Mars.jar
    install -Dm444 $src $JAR
    makeWrapper ${jre}/bin/java $out/bin/Mars \
      --add-flags "-jar $JAR"

    unzip $src images/MarsThumbnail.gif
    for size in 16 24 32 48 64 128 256 512
    do
      mkdir -p $out/share/icons/hicolor/"$size"x"$size"/apps
      convert -resize "$size"x"$size" images/MarsThumbnail.gif $out/share/icons/hicolor/"$size"x"$size"/apps/mars.png
    done

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Development"
        "IDE"
      ];

      comment = finalAttrs.meta.description;
      desktopName = "MARS";
      exec = "Mars";
      icon = "mars";
      name = "mars";
    })
  ];

  dontUnpack = true;

  meta = {
    description = "IDE for programming in MIPS assembly language intended for educational-level use";
    homepage = "https://courses.missouristate.edu/KenVollmar/MARS/";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ emilytrau ];
    platforms = lib.platforms.all;
    mainProgram = "Mars";
  };
})
