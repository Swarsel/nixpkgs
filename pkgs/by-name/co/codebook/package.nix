{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "codebook";
  version = "0.3.42";

  src = fetchFromGitHub {
    owner = "blopker";
    repo = "codebook";
    tag = "v${finalAttrs.version}";
    hash = "sha256-L+OVR7JHs9qFh48ET2eugl4zZIpbM4DBtoWsHKzKbks=";
  };

  cargoHash = "sha256-+OmaZkae5b5TKfMwlYGijJTD5gGS/YuoQOvKKfKuipk=";

  env = {
    CARGO_PROFILE_RELEASE_CODEGEN_UNITS = "1";
    CARGO_PROFILE_RELEASE_LTO = "fat";
  };

  # Integration tests require internet access for dictionaries
  doCheck = false;
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  buildAndTestSubdir = "crates/codebook-lsp";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Unholy spellchecker for code";
    homepage = "https://github.com/blopker/codebook";
    changelog = "https://github.com/blopker/codebook/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      jpds
    ];

    platforms = with lib.platforms; unix ++ windows;
    mainProgram = "codebook-lsp";
  };
})
