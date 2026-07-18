{
  lib,
  fetchFromGitHub,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rwalk";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "cestef";
    repo = "rwalk";
    tag = "v${finalAttrs.version}";
    hash = "sha256-W42b3fUezMpOPaNmTogUbgn67nCiKteCkkYUAux9Ng4=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-9zZLHjDpnxL3aR8zX4eNU1mpMDzMqzMC+Wr+DWVimUo=";

  env = {
    OPENSSL_NO_VENDOR = true;
  };

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Blazingly fast web directory scanner written in Rust";
    homepage = "https://github.com/cestef/rwalk";
    changelog = "https://github.com/cestef/rwalk/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pwnwriter ];
    mainProgram = "rwalk";
  };
})
