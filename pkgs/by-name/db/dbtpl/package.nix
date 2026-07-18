{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  buildPackages,
  installShellFiles,
  nix-update-script,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "dbtpl";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "xo";
    repo = "dbtpl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-r0QIgfDSt7HWnIDnJWGbwkqkXWYWGXoF5H/+zS6gEtE=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  vendorHash = "sha256-scJRJaaccQovxhzC+/OHuPR4NRaE8+u57S1JY40bif8=";

  postInstall =
    let
      exe =
        if stdenv.buildPlatform.canExecute stdenv.hostPlatform then
          "$out/bin/dbtpl"
        else
          lib.getExe buildPackages.dbtpl;
    in
    ''
      installShellCompletion --cmd dbtpl \
        --bash <(${exe} completion bash) \
        --fish <(${exe} completion fish) \
        --zsh <(${exe} completion zsh)
    '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  modPostBuild = ''
    substituteInPlace vendor/github.com/xo/ox/ox.go \
        --replace-warn "ver := \"(devel)\"" "ver := \"${finalAttrs.version}\""
  '';

  versionCheckProgramArg = "version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Command line tool to generate idiomatic Go code for SQL databases supporting PostgreSQL, MySQL, SQLite, Oracle, and Microsoft SQL Server";
    homepage = "https://github.com/xo/dbtpl";
    changelog = "https://github.com/xo/dbtpl/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      xiaoxiangmoe
      shellhazard
    ];

    mainProgram = "dbtpl";
  };
})
