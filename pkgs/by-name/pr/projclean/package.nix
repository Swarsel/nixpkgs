{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "projclean";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "sigoden";
    repo = "projclean";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lVXqaN8zaJ/T9ot2ONKjOJfejWjsHLNG3d3o8sdaYQM=";
  };

  cargoHash = "sha256-jVONodcFCdjKOt7GkIUlWw+4yisDNJ/srqqP99gdsAc=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Project dependencies & build artifacts cleanup tool";
    homepage = "https://github.com/sigoden/projclean";

    license = with lib.licenses; [
      mit
      asl20
    ];

    maintainers = with lib.maintainers; [ chillcicada ];
    mainProgram = "projclean";
  };
})
