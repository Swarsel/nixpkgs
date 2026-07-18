{
  lib,
  stdenv,
  fetchFromCodeberg,
  installShellFiles,
  libgit2,
  oniguruma,
  openssl,
  pkg-config,
  rustPlatform,
  versionCheckHook,
  writableTmpDirAsHomeHook,
  zlib,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "forgejo-cli";
  version = "0.5.0";

  src = fetchFromCodeberg {
    owner = "forgejo-contrib";
    repo = "forgejo-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6qouGcqNau2aCBPYpn0hFdm8QXL1WjZvnowK4aspe/Q=";
  };

  nativeBuildInputs = [
    pkg-config
    installShellFiles
    writableTmpDirAsHomeHook # Needed for shell completions
  ];

  buildInputs = [
    libgit2
    oniguruma
    openssl
    zlib
  ];

  cargoHash = "sha256-UPDhPKC/x0ccfm7Df74PtCn+Zt9ShCxf9uB5TVaYV6Y=";

  env = {
    BUILD_TYPE = "nixpkgs";
    RUSTONIG_SYSTEM_LIBONIG = true;
  };

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd fj \
      --bash <($out/bin/fj completion bash) \
      --fish <($out/bin/fj completion fish) \
      --zsh <($out/bin/fj completion zsh)
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;
  versionCheckProgramArg = "version";

  meta = {
    description = "CLI application for interacting with Forgejo";
    homepage = "https://codeberg.org/forgejo-contrib/forgejo-cli";
    changelog = "https://codeberg.org/forgejo-contrib/forgejo-cli/releases/tag/v${finalAttrs.version}";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = with lib.maintainers; [
      da157
      isabelroses
    ];

    mainProgram = "fj";
  };
})
