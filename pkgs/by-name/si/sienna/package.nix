{
  lib,
  stdenv,
  fetchurl,
  copyDesktopItems,
  love,
  makeDesktopItem,
  makeWrapper,
}:

stdenv.mkDerivation rec {
  pname = "sienna";
  version = "1.0d";

  src = fetchurl {
    url = "https://github.com/SimonLarsen/sienna/releases/download/v${version}/sienna-${version}.love";
    hash = "sha256-1bFjhN7jL/PMYMJH1ete6uyHTYsTGgoP60sf/sJTLlU=";
  };

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    mkdir -p $out/share/games/lovegames

    cp -v $src $out/share/games/lovegames/sienna.love

    makeWrapper ${lib.getExe love} $out/bin/sienna --add-flags $out/share/games/lovegames/sienna.love
    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Game" ];
      comment = "Fast-paced one button platformer";
      desktopName = "Sienna";
      exec = "sienna";
      genericName = "sienna";
      icon = icon;
      name = "sienna";
    })
  ];

  dontUnpack = true;

  icon = fetchurl {
    hash = "sha256-1grwCi1sKelqEH58pO0rTSnqG7JOfVByNKu2NCbMAos=";
    url = "http://tangramgames.dk/img/thumb/sienna.png";
  };

  meta = {
    description = "Fast-paced one button platformer";
    homepage = "https://tangramgames.dk/games/sienna";
    license = lib.licenses.zlib;
    maintainers = [ ];
    platforms = love.meta.platforms;
    mainProgram = "sienna";
  };

}
