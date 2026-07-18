{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "wkg";
  version = "0.15.1";

  src = fetchFromGitHub {
    owner = "bytecodealliance";
    repo = "wasm-pkg-tools";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xWwhRqo/rRa+VPe2RqoZf77pf3YjqCdbOG8axme9oW4=";
  };

  cargoHash = "sha256-L0KYEnmvTUI6GreuEDf6QzNkTHzsLo/U27RrSwF5sA4=";
  # A large number of tests require Internet access in order to function.
  doCheck = false;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tools to package up WASM Components";
    homepage = "https://github.com/bytecodealliance/wasm-pkg-tools";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ water-sucks ];
    mainProgram = "wkg";
  };
})
