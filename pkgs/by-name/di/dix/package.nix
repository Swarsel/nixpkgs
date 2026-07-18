{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "dix";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "manic-systems";
    repo = "dix";
    tag = "v${finalAttrs.version}";
    hash = "sha256-U7zKSFQsmAkG4Um0DxgkgsGKh+/MqT1H3llUVd/i8UE=";
  };

  cargoHash = "sha256-m2jRDMjZTJHKbe0Ep76SFT3tV1xytThvaRAt6A0CF3A=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Blazingly fast tool to diff Nix related things";
    homepage = "https://github.com/manic-systems/dix";
    changelog = "https://github.com/manic-systems/dix/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      faukah
      NotAShelf
    ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    mainProgram = "dix";
  };
})
