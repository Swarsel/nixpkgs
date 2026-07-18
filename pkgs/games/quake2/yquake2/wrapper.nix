{
  lib,
  stdenv,
  buildEnv,
  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,
  yquake2,
}:

{
  description,
  games,
  name,
}:

let
  env = buildEnv {
    name = "${name}-env";
    paths = [ yquake2 ] ++ games;
  };

in
stdenv.mkDerivation {
  pname = name;
  version = lib.getVersion yquake2;

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
  ''
  + lib.concatMapStringsSep "\n" (game: ''
    makeWrapper ${env}/bin/yquake2 $out/bin/yquake2-${game.title} \
      --add-flags "+set game ${game.id}"
    makeWrapper ${env}/bin/yq2ded $out/bin/yq2ded-${game.title} \
      --add-flags "+set game ${game.id}"
  '') games
  + ''
    install -Dm644 ${yquake2}/share/icons/hicolor/512x512/apps/yamagi-quake2.png $out/share/icons/hicolor/512x512/apps/yamagi-quake2.png;
    runHook postInstall
  '';

  desktopItems = map (
    game:
    makeDesktopItem {
      categories = [
        "Game"
        "Shooter"
      ];

      comment = game.description;
      desktopName = game.id;
      exec = game.title;
      icon = "yamagi-quake2";
      name = game.id;
    }
  ) games;

  dontUnpack = true;

  meta = {
    inherit description;
  };
}
