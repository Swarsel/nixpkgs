{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "desed";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "SoptikHa2";
    repo = "desed";
    tag = "v${finalAttrs.version}";
    hash = "sha256-aKkOs8IhnHjoJkXq9ryGn9fN0AmZyVTHbD/Vano+Erw=";
  };

  cargoHash = "sha256-1vNs+viEPqmfA8AtFQaGcQwlLAbIBMHd8uMFmqm60eg=";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Debugger for Sed: demystify and debug your sed scripts, from comfort of your terminal";
    homepage = "https://github.com/SoptikHa2/desed";
    changelog = "https://github.com/SoptikHa2/desed/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ vinylen ];
    mainProgram = "desed";
  };
})
