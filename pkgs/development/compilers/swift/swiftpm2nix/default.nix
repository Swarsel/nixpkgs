{
  lib,
  stdenv,
  callPackage,
  jq,
  makeWrapper,
  nurl,
}:

stdenv.mkDerivation {
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    install -vD ${./swiftpm2nix.sh} $out/bin/swiftpm2nix
    wrapProgram $out/bin/$name \
      --prefix PATH : ${
        lib.makeBinPath [
          jq
          nurl
        ]
      }
  '';

  dontUnpack = true;
  name = "swiftpm2nix";
  preferLocalBuild = true;
  passthru = callPackage ./support.nix { };

  meta = {
    description = "Generate a Nix expression to fetch swiftpm dependencies";
    platforms = lib.platforms.all;
    mainProgram = "swiftpm2nix";
    teams = [ lib.teams.swift ];
  };
}
