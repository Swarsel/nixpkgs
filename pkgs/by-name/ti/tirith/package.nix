{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (final: {
  pname = "tirith";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "sheeki03";
    repo = "tirith";
    tag = "v${final.version}";
    hash = "sha256-RdStW5ubqypdmFqNk9DHtUp5jHnZdXiWW/lAlSaBb3c=";
  };

  postPatch = ''
    # The bash_preexec_enforce tests require a shell with job control
    rm crates/tirith/tests/bash_preexec_enforce.rs
  '';

  nativeBuildInputs = lib.optionals (stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    installShellFiles
  ];

  cargoHash = "sha256-/V2vv02x0zSsJCcJMSttG9eekRZMK7KTk6m2VYePFa8=";

  checkFlags = [
    # requires a fully functional shell environment, generating init scripts needs a patch under nix to work at build time
    "--skip=init_bash_output"
    "--skip=init_zsh_output"
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd tirith \
      --bash <("$out/bin/tirith" completions bash) \
      --zsh <("$out/bin/tirith" completions zsh) \
      --fish <("$out/bin/tirith" completions fish)
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __darwinAllowLocalNetworking = true;

  cargoBuildFlags = [
    "-p"
    "tirith"
  ];

  meta = {
    description = "Shell security tool that guards against homograph URL attacks, pipe-to-shell exploits, and other command-line threats before they execute";
    homepage = "https://github.com/sheeki03/tirith";
    changelog = "https://github.com/sheeki03/tirith/blob/${final.src.tag}/CHANGELOG.md";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ toasteruwu ];
    platforms = lib.platforms.unix;
    mainProgram = "tirith";
  };
})
