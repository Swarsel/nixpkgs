{
  lib,
  makeWrapper,
  nix,
  nix-index-unwrapped,
  symlinkJoin,
}:

symlinkJoin {
  inherit (nix-index-unwrapped) pname version meta;
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    wrapProgram $out/bin/nix-index \
      --prefix PATH : ${lib.makeBinPath [ nix ]}
  '';

  paths = [ nix-index-unwrapped ];
}
