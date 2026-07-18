{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  elmPackages,
}:

buildNpmPackage (finalAttrs: {
  pname = "elm-verify-examples";
  version = "6.0.3";

  src = fetchFromGitHub {
    owner = "stoeffel";
    repo = "elm-verify-examples";
    tag = "v${finalAttrs.version}";
    hash = "sha256-HUmIrwmJyGvkCRHRiA069Aj25WBIGtJ7DJxwwF6OvWU=";
  };

  nativeBuildInputs = [
    elmPackages.elm
  ];

  npmDepsHash = "sha256-frNCo97GOwiClzQwRXHpqqjimJrmipsBebAshJqGZco=";

  postConfigure = (
    elmPackages.fetchElmDeps {
      elmPackages = import ./elm-srcs.nix;
      elmVersion = elmPackages.elm.version;
      registryDat = ./registry.dat;
    }
  );

  buildPhase = ''
    runHook preBuild
    make build
    runHook postBuild
  '';

  npmFlags = [ "--ignore-scripts" ];
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Verify examples in your docs";
    homepage = "https://github.com/stoeffel/elm-verify-examples";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    mainProgram = "elm-verify-examples";
  };
})
