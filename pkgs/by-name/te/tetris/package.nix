{
  haskell,
  haskellPackages,
}:

haskell.lib.compose.justStaticExecutables (
  haskellPackages.callPackage (
    {
      lib,
      fetchFromGitHub,
      base,
      brick,
      containers,
      directory,
      extra,
      filepath,
      lens,
      linear,
      mkDerivation,
      mtl,
      optparse-applicative,
      random,
      transformers,
      vty,
      vty-crossplatform,
    }:
    mkDerivation rec {
      pname = "tetris";
      version = "0.1.6";

      src = fetchFromGitHub {
        owner = "Samtay";
        repo = "tetris";
        tag = "v${version}";
        hash = "sha256-xA2/n5zY01BLKlUI8BVvfuUvsqh2U23XOooTQwXkDpQ=";
      };

      changelog = "https://github.com/samtay/tetris/releases/tag/v${version}";

      executableHaskellDepends = [
        base
        directory
        filepath
        optparse-applicative
      ];

      homepage = "https://github.com/samtay/tetris";

      libraryHaskellDepends = [
        base
        brick
        containers
        extra
        lens
        linear
        mtl
        random
        transformers
        vty
        vty-crossplatform
      ];

      license = lib.licenses.bsd3;
      mainProgram = "tetris";
      maintainers = [ lib.maintainers.Svenum ];
    }
  ) { }
)
