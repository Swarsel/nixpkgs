{
  lib,
  stdenv,
  buildNpmPackage,
  clang_20,
  fetchzip,
  patches ? [ ],
}:

let
  releaseData = (lib.importJSON ./release-data.json).plugins."io.github.jackgruber.backup";
in

buildNpmPackage {
  inherit (releaseData) npmDepsHash;
  inherit patches;

  src = fetchzip {
    inherit (releaseData) url hash;
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isDarwin [
    clang_20 # clang_21 breaks keytar
  ];

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out publish/*.jpl

    runHook postInstall
  '';

  name = "joplin-plugin-backup";
  npmBuildScript = "dist";
}
