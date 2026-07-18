{
  lib,
  fetchFromGitHub,
  curl,
  installShellFiles,
  libxml2,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "hurl";
  version = "8.0.1";

  src = fetchFromGitHub {
    owner = "Orange-OpenSource";
    repo = "hurl";
    tag = finalAttrs.version;
    hash = "sha256-DVxY7vjZpcqptq/4CUxo5WX7+Bf9o/sxGobZ7+BMXHM=";
  };

  nativeBuildInputs = [
    pkg-config
    installShellFiles
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    libxml2
    openssl
    curl
  ];

  cargoHash = "sha256-rBn14XK1DrwRfe4Mo0aezF4lLhQf4PtsRYkuM1wcZXU=";
  # The actual tests require network access to a test server, but we can run an install check
  doCheck = false;

  postInstall = ''
    installManPage docs/manual/hurl.1 docs/manual/hurlfmt.1
    installShellCompletion --cmd hurl \
      --bash completions/hurl.bash \
      --zsh completions/_hurl \
      --fish completions/hurl.fish

    installShellCompletion --cmd hurlfmt \
      --zsh completions/_hurlfmt
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Command line tool that performs HTTP requests defined in a simple plain text format";
    homepage = "https://hurl.dev/";
    changelog = "https://github.com/Orange-OpenSource/hurl/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      eonpatapon
      defelo
    ];

    mainProgram = "hurl";
  };
})
