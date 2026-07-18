{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  testers,
  writableTmpDirAsHomeHook,
}:

buildGoModule (finalAttrs: {
  pname = "harbor-cli";
  version = "0.0.24";

  src = fetchFromGitHub {
    owner = "goharbor";
    repo = "harbor-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XL9w33ZPmB0imK8dudxj4zoUxDbUdpWaCu8u/1c6wG4=";
  };

  nativeBuildInputs = [
    installShellFiles
    writableTmpDirAsHomeHook
  ];

  vendorHash = "sha256-Iy+Kf0Kf1yuFk+shbomT0Z1zMvAbdWT4vLshAjlqvck=";
  doCheck = false; # Network required

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd harbor \
      --bash <($out/bin/harbor completion bash) \
      --fish <($out/bin/harbor completion fish) \
      --zsh <($out/bin/harbor completion zsh)
  '';

  excludedPackages = [
    "dagger"
    "doc"
  ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/goharbor/harbor-cli/cmd/harbor/internal/version.Version=${finalAttrs.version}"
  ];

  passthru.tests.version = testers.testVersion {
    command = "HOME=\"$(mktemp -d)\" harbor version";
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "Command-line tool facilitates seamless interaction with the Harbor container registry";
    homepage = "https://github.com/goharbor/harbor-cli";
    changelog = "https://github.com/goharbor/harbor-cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ aaronjheng ];
    mainProgram = "harbor";
  };
})
