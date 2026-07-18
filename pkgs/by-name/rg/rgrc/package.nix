{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rgrc";
  version = "0.6.14";

  src = fetchFromGitHub {
    owner = "lazywalker";
    repo = "rgrc";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DEsxdqX9kAK/TqmP8PMOLQE4ij0+8mkoK/QapbXikss=";
  };

  nativeBuildInputs = [ installShellFiles ];
  cargoHash = "sha256-OLDMaHwrDO4Q4V0hVIbXmkTiBowpGoZc/xOISwS25Nc=";
  checkFlags = [ "--skip=test_command_exists" ];

  postInstall = ''
    installManPage doc/rgrc.1
    install -Dm644 share/conf.* -t $out/share/rgrc/
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd rgrc \
      --bash <($out/bin/rgrc --completions bash) \
      --fish <($out/bin/rgrc --completions fish) \
      --zsh <($out/bin/rgrc --completions zsh)
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  buildFeatures = [ "embed-configs" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Rusty Generic Colouriser - just like grc but fast";
    homepage = "https://lazywalker.github.io/rgrc/";
    changelog = "https://github.com/lazywalker/rgrc/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sedlund ];
    mainProgram = "rgrc";
  };
})
