{
  lib,
  buildEnv,
  callPackage,
  makeWrapper,
}:

buildEnv {
  pname = "flare";
  version = "1.15";
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    mkdir -p $out/bin
    makeWrapper $out/games/flare $out/bin/flare --chdir "$out/share/games/flare"
  '';

  paths = [
    (callPackage ./engine.nix { })
    (callPackage ./game.nix { })
  ];

  meta = {
    description = "Fantasy action RPG using the FLARE engine";
    homepage = "https://flarerpg.org/";

    license = [
      lib.licenses.gpl3
      lib.licenses.cc-by-sa-30
    ];

    maintainers = with lib.maintainers; [
      aanderse
      McSinyx
    ];

    platforms = lib.platforms.unix;
    mainProgram = "flare";
  };
}
