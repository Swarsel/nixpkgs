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
  pname = "ssh-vault";
  version = "1.2.14";

  src = fetchFromGitHub {
    owner = "ssh-vault";
    repo = "ssh-vault";
    tag = finalAttrs.version;
    hash = "sha256-wxiADf5KjAD/lZBOYb7vbWYcfw9Xmk+gHmN9cPQ0vvI=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-Ab6XXCdT97reDJYqZBLELH2XgBYHZ4pLF/byELWy4j8=";

  # `test_setup_io` requires to be executed in an interactive shell
  checkFlags = [
    "--skip"
    "vault::dio::tests::test_setup_io"
  ];

  preCheck = ''
    export HOME=$(mktemp -d)
    mkdir --parents $HOME/.ssh/vault
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Encrypt/decrypt using SSH keys";
    homepage = "https://github.com/ssh-vault/ssh-vault";
    changelog = "https://github.com/ssh-vault/ssh-vault/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ yiyu ];
    mainProgram = "ssh-vault";
  };
})
