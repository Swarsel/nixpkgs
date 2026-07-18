{
  lib,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  stdenvNoCC,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "go-chromecast";
  version = "0.3.4";

  src = fetchFromGitHub {
    owner = "vishen";
    repo = "go-chromecast";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FFe87Z0aiNP5aGAiJ2WJkKRAMCQGWEBB0gLDGBpE3fk=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-MOC9Yqo5p02eZLFJYBE8CxHxZv3RcpqV2sEPZOWiDeE=";
  env.CGO_ENABLED = 0;

  postInstall = lib.optionalString (stdenvNoCC.buildPlatform.canExecute stdenvNoCC.hostPlatform) ''
    installShellCompletion --cmd go-chromecast \
      --bash <($out/bin/go-chromecast completion bash) \
      --fish <($out/bin/go-chromecast completion fish) \
      --zsh <($out/bin/go-chromecast completion zsh)
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  ldflags = [
    "-s"
    "-w"
    "-X=main.version=${finalAttrs.version}"
    "-X=main.commit=${finalAttrs.src.rev}"
    "-X=main.date=unknown"
  ];

  meta = {
    description = "CLI for Google Chromecast, Home devices and Cast Groups";
    homepage = "https://github.com/vishen/go-chromecast";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.zi3m5f ];
    mainProgram = "go-chromecast";
  };
})
