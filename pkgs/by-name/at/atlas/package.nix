{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "atlas";
  version = "1.2.3";

  src = fetchFromGitHub {
    owner = "ariga";
    repo = "atlas";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Ox/EgTSz0ONEJqLyiJsvpgUNfHyV2rQYXrIAImDwrLo=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-9yg8VkRtyaMQjCAAOHIG4A9QSV1VOFOLBK9cTrE83a4=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd atlas \
      --bash <($out/bin/atlas completion bash) \
      --fish <($out/bin/atlas completion fish) \
      --zsh <($out/bin/atlas completion zsh)
  '';

  ldflags = [
    "-s"
    "-w"
    "-X ariga.io/atlas/cmd/atlas/internal/cmdapi.version=v${finalAttrs.version}"
  ];

  modRoot = "cmd/atlas";
  proxyVendor = true;
  subPackages = [ "." ];

  passthru.tests.version = testers.testVersion {
    version = "v${finalAttrs.version}";
    command = "atlas version";
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "Manage your database schema as code";
    homepage = "https://atlasgo.io/";
    changelog = "https://github.com/ariga/atlas/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ aaronjheng ];
    mainProgram = "atlas";
  };
})
