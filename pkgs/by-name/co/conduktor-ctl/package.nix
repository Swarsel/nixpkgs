{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "conduktor-ctl";
  version = "0.6.3";

  src = fetchFromGitHub {
    owner = "conduktor";
    repo = "ctl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zaguB4LLkzXlMQCEVOWkUUsEovU53F0B51w3BnVjre8=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-h9NSOkqpkZ3sKcfsPjF+T2JgX0N8CIAP6y1NVIb/r0E=";

  checkPhase = ''
    go test ./...
  '';

  postInstall = ''
    mv $out/bin/ctl $out/bin/conduktor
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd conduktor \
      --bash <($out/bin/conduktor completion bash) \
      --fish <($out/bin/conduktor completion fish) \
      --zsh <($out/bin/conduktor completion zsh)
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  ldflags = [ "-X github.com/conduktor/ctl/utils.version=${finalAttrs.version}" ];
  versionCheckProgram = "${placeholder "out"}/bin/conduktor";
  versionCheckProgramArg = "version";

  meta = {
    description = "CLI tool to interact with the Conduktor Console and Gateway";
    homepage = "https://github.com/conduktor/ctl";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      conduktorbot
      marnas
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "conduktor";
  };
})
