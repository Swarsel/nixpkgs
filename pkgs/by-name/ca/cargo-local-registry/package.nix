{
  lib,
  fetchFromGitHub,
  curl,
  libgit2,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  versionCheckHook,
  zlib,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-local-registry";
  version = "0.2.12";

  src = fetchFromGitHub {
    owner = "dhovart";
    repo = "cargo-local-registry";
    tag = "v${finalAttrs.version}";
    hash = "sha256-b0twS9Vhz1FcsHXNtePYi+PIY7yqgrH4kgqdf2jqF7w=";
  };

  nativeBuildInputs = [
    curl
    pkg-config
  ];

  buildInputs = [
    curl
    libgit2
    openssl
    zlib
  ];

  cargoHash = "sha256-Cp54HkQ+8fG85wfFof5cexyAxo9spv78TstEEyKK7RE=";
  # tests require internet access
  doCheck = false;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Cargo subcommand to manage local registries";
    homepage = "https://github.com/dhovart/cargo-local-registry";
    changelog = "https://github.com/dhovart/cargo-local-registry/releases/tag/v${finalAttrs.version}";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = [ lib.maintainers.progrm_jarvis ];
    mainProgram = "cargo-local-registry";
  };
})
