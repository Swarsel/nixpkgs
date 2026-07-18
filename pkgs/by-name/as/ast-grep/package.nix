{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
  enableLegacySg ? false,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ast-grep";
  version = "0.44.1";

  src = fetchFromGitHub {
    owner = "ast-grep";
    repo = "ast-grep";
    tag = finalAttrs.version;
    hash = "sha256-C6JwLx6z+/xSm9kMF48hfd3WTRax8Bdy3zgGeYxGyg8=";
  };

  # error: linker `aarch64-linux-gnu-gcc` not found
  postPatch = ''
    rm .cargo/config.toml
  '';

  nativeBuildInputs = [ installShellFiles ];
  cargoHash = "sha256-waeAXcxnvTWbuAhVWdA5wPdWvS1aSSptGerFoGEtFUE=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd ast-grep \
      --bash <($out/bin/ast-grep completions bash) \
      --fish <($out/bin/ast-grep completions fish) \
      --zsh <($out/bin/ast-grep completions zsh)
    ${lib.optionalString enableLegacySg ''
      installShellCompletion --cmd sg \
        --bash <($out/bin/sg completions bash) \
        --fish <($out/bin/sg completions fish) \
        --zsh <($out/bin/sg completions zsh)
    ''}
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  cargoBuildFlags = [
    "--package ast-grep --bin ast-grep"
  ]
  ++ lib.optionals enableLegacySg [ "--package ast-grep --bin sg" ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fast and polyglot tool for code searching, linting, rewriting at large scale";
    homepage = "https://ast-grep.github.io/";
    changelog = "https://github.com/ast-grep/ast-grep/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      xiaoxiangmoe
      astratagem
      lord-valen
      cafkafk
    ];

    mainProgram = "ast-grep";
  };
})
