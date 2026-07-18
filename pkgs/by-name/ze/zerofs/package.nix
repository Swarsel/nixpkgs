{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "zerofs";
  version = "2.0.6";

  src = fetchFromGitHub {
    owner = "Barre";
    repo = "ZeroFS";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xQOuMBScZn1I2SgmVKvZpKy95+/82SBI/kvl+zrzlT4=";
  };

  nativeBuildInputs = [ cmake ];
  cargoHash = "sha256-ewqv2b1/T1Zl7oLKbCVNbt8jLURlFKyGQVatAl0B9Nc=";

  env = {
    RUSTFLAGS = "--cfg tokio_unstable";
  };

  checkFlags = [
    # fails with NotPermitted inside the build sandbox
    "--skip=zerofs_client_tests::metadata_operations"
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  sourceRoot = "${finalAttrs.src.name}/zerofs";
  versionCheckProgramArg = "--version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Filesystem That Makes S3 your Primary Storage.";

    longDescription = ''
      ZeroFS makes S3 storage feel like a real filesystem. It provides file-level access
      via NFS and 9P and block-level access via NBD.
    '';

    homepage = "https://www.zerofs.net";
    changelog = "https://github.com/Barre/ZeroFS/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      lblasc
    ];

    mainProgram = "zerofs";
  };
})
