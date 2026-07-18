{
  lib,
  stdenv,
  fetchFromGitHub,
  curl,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-tarpaulin";
  version = "0.37.0";

  src = fetchFromGitHub {
    owner = "xd009642";
    repo = "tarpaulin";
    tag = finalAttrs.version;
    hash = "sha256-8LD4huR6xcksxkxF3Axoh5tx3FQgzE8nYVSpeSdY7us=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    curl
  ];

  cargoHash = "sha256-FH0skHQ0eR9qgoCqDqO+NZZLzBw8U/ijNUupTYexIGI=";
  doCheck = false;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Code coverage tool for Rust projects";
    homepage = "https://github.com/xd009642/tarpaulin";
    changelog = "https://github.com/xd009642/tarpaulin/blob/${finalAttrs.version}/CHANGELOG.md";

    license = with lib.licenses; [
      mit # or
      asl20
    ];

    maintainers = with lib.maintainers; [
      hugoreeves
      progrm_jarvis
    ];

    mainProgram = "cargo-tarpaulin";
  };
})
