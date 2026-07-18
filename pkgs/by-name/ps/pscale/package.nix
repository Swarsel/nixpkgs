{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  pscale,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "pscale";
  version = "0.293.0";

  src = fetchFromGitHub {
    owner = "planetscale";
    repo = "cli";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-eROK3Bqp72rhUTUUZZlIUbMLTNmjEUXw2TBSsNVLONQ=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-IkqXij3i3nUCHfu36yS7e4+5PM6ZHmPuYbgVo7Uv0X8=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd pscale \
      --bash <($out/bin/pscale completion bash) \
      --fish <($out/bin/pscale completion fish) \
      --zsh <($out/bin/pscale completion zsh)
  '';

  __darwinAllowLocalNetworking = true;

  ldflags = [
    "-s"
    "-w"
    "-X main.version=v${finalAttrs.version}"
    "-X main.commit=v${finalAttrs.version}"
    "-X main.date=unknown"
  ];

  passthru.tests.version = testers.testVersion {
    package = pscale;
  };

  meta = {
    description = "CLI for PlanetScale Database";
    homepage = "https://www.planetscale.com/";
    changelog = "https://github.com/planetscale/cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      kashw2
    ];

    mainProgram = "pscale";
  };
})
