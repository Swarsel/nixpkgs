{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "typstyle";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "typstyle-rs";
    repo = "typstyle";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CIIuj8sKy0XTCKbpNGHZQOQp0SszIutjeqhjmDeU2UU=";
  };

  cargoHash = "sha256-TLYefRh32AP4WozN2nLdXiENbqnXHRqGT4BRJX52MLI=";

  # Disabling tests requiring network access
  checkFlags = [
    "--skip=e2e"
  ];

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Format your typst source code";
    homepage = "https://github.com/typstyle-rs/typstyle";
    changelog = "https://github.com/typstyle-rs/typstyle/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      prince213
    ];

    mainProgram = "typstyle";
  };
})
