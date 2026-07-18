{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "hatsu";
  version = "0.3.4";

  src = fetchFromGitHub {
    owner = "importantimport";
    repo = "hatsu";
    tag = "v${finalAttrs.version}";
    hash = "sha256-66BNgcCYPMJ5AE/OCfbLrU+A/usv0/QvcyPy8D+7PVs=";
  };

  cargoHash = "sha256-NXauXnCpk8YjiX4bqZMbEy/QPb7MiJYzY64YKDV6qq0=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Self-hosted and fully-automated ActivityPub bridge for static sites";
    homepage = "https://github.com/importantimport/hatsu";
    changelog = "https://github.com/importantimport/hatsu/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ kwaa ];
    platforms = lib.platforms.linux;
    mainProgram = "hatsu";
  };
})
