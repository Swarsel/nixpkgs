{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rsonpath";
  version = "0.10.1";

  src = fetchFromGitHub {
    owner = "rsonquery";
    repo = "rsonpath";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pgKqVDDaJ8vcDOp0FuuuBkShQDFP3x6BVS7x8ZZawAY=";
  };

  cargoHash = "sha256-PC35k3vwKP55VKZt1txKVajhfrJpFiEgJYA4lNe/U7U=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  cargoBuildFlags = [ "-p=rsonpath" ];
  cargoTestFlags = finalAttrs.cargoBuildFlags;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Experimental JSONPath engine for querying massive streamed datasets";
    homepage = "https://github.com/v0ldek/rsonpath";
    changelog = "https://github.com/v0ldek/rsonpath/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      tbutter
      progrm_jarvis
    ];

    mainProgram = "rq";
  };
})
