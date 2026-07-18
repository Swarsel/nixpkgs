{
  lib,
  cabal2nix-unwrapped,
  makeWrapper,
  nix-prefetch-scripts,
  symlinkJoin,
}:

symlinkJoin {
  inherit (cabal2nix-unwrapped) pname version meta;
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    wrapProgram $out/bin/cabal2nix \
      --prefix PATH ":" "${
        lib.makeBinPath [
          nix-prefetch-scripts
        ]
      }"
  '';

  paths = [ cabal2nix-unwrapped ];
}
