{
  lib,
  fetchFromRadicle,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rad-key";
  version = "0.1.1";

  src = fetchFromRadicle {
    repo = "zFF3JpT1VrrsDYogDPtVZMHw6P4x";
    tag = "releases/${finalAttrs.version}";
    hash = "sha256-0lPVkgBHfIG4fF/JuEnRznnHR9VaX91UBjmHqoFj2rk=";
    seed = "radicle.defelo.de";
  };

  cargoHash = "sha256-W/4h+hvsmydZim4HrylLWADINRcwP8cOgoBtPbuSxKY=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Convert between Radicle identities and public SSH keys";
    homepage = "https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zFF3JpT1VrrsDYogDPtVZMHw6P4x";
    license = lib.licenses.mit;
    mainProgram = "rad-key";
    teams = [ lib.teams.radicle ];
  };
})
