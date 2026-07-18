{
  lib,
  fetchFromGitHub,
  buildGoModule,
  go,
  nix-update-script,
  testers,
  vcluster,
}:

buildGoModule (finalAttrs: {
  pname = "vcluster";
  version = "0.35.1";

  src = fetchFromGitHub {
    owner = "loft-sh";
    repo = "vcluster";
    tag = "v${finalAttrs.version}";
    hash = "sha256-31PGY6x+D0QJCS8VyTPS2AVEB/aw1hV/miijsqwpALI=";
  };

  vendorHash = null;
  # Test is disabled because e2e tests expect k8s.
  doCheck = false;

  installPhase = ''
    runHook preInstall

    install -Dm755 $GOPATH/bin/vclusterctl $out/bin/vcluster

    runHook postInstall
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
    "-X main.goVersion=${lib.getVersion go}"
  ];

  subPackages = [ "cmd/vclusterctl" ];

  passthru.tests.version = testers.testVersion {
    command = "HOME=$(mktemp -d) vcluster --version";
    package = vcluster;
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Create fully functional virtual Kubernetes clusters";
    homepage = "https://www.vcluster.com/";
    changelog = "https://github.com/loft-sh/vcluster/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      qjoly
      roehrijn
    ];

    mainProgram = "vcluster";
    downloadPage = "https://github.com/loft-sh/vcluster";
  };
})
