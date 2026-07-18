{
  lib,
  buildEnv,
  callPackage,
  makeDesktopItem,
  makeWrapper,
}:

let
  description = "Action-adventure game, starring a certain quixotic frog";
  engine = callPackage ./engine.nix { };
  data = callPackage ./data.nix { };
  desktopItem = makeDesktopItem {
    categories = [
      "Game"
      "ArcadeGame"
    ];

    comment = description;
    desktopName = "Frogatto";
    exec = "frogatto";
    genericName = "frogatto";
    icon = "${data}/share/frogatto/modules/frogatto/images/os/frogatto-icon.png";
    name = "frogatto";
    startupNotify = true;
  };
  inherit (data) version;
in
buildEnv {
  inherit version;
  pname = "frogatto";
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    wrapProgram $out/bin/frogatto \
      --chdir "$out/share/frogatto"
  '';

  paths = [
    engine
    data
    desktopItem
  ];

  pathsToLink = [
    "/bin"
    "/share/frogatto/data"
    "/share/frogatto/images"
    "/share/frogatto/modules"
    "/share/applications"
  ];

  meta = {
    description = description;
    homepage = "https://frogatto.com";

    license = with lib.licenses; [
      cc-by-30
      unfree
    ];

    maintainers = with lib.maintainers; [ astro ];
    platforms = lib.platforms.linux;
  };
}
