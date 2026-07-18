{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  nix-update-script,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "ghatm";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "suzuki-shunsuke";
    repo = "ghatm";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MX1VilyfxJ9GKIkDSGeAE007DyjPkWL5W4b08EqAyC4=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-CQ2HAyBuULKbmGdJ9RmPYFr2nZYxDePoJu+k8cjKxpk=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd ghatm \
      --bash <($out/bin/ghatm completion bash) \
      --zsh <($out/bin/ghatm completion zsh) \
      --fish <($out/bin/ghatm completion fish)
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
    "-X main.commit=v${finalAttrs.version}"
  ];

  versionCheckProgramArg = "version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Set timeout-minutes to all GitHub Actions jobs";
    homepage = "https://github.com/suzuki-shunsuke/ghatm";
    changelog = "https://github.com/suzuki-shunsuke/ghatm/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ HeitorAugustoLN ];
    platforms = lib.platforms.all;
    mainProgram = "ghatm";
  };
})
