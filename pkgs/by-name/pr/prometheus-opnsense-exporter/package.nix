{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "prometheus-opnsense-exporter";
  version = "0.0.16";

  src = fetchFromGitHub {
    owner = "AthennaMind";
    repo = "opnsense-exporter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-oAQm2bxcDQfqTdtVtot1Dk2MkFqG5wVxeERie5DRoOQ=";
  };

  vendorHash = null;
  doInstallCheck = true;

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/prometheus/common/version.BuildDate=1970-01-01T00:00:00Z"
    "-X github.com/prometheus/common/version.BuildUser=nix@nixpkgs"
    "-X github.com/prometheus/common/version.Branch=master"
    "-X github.com/prometheus/common/version.Revision=${finalAttrs.src.rev}"
    "-X github.com/prometheus/common/version.Version=${finalAttrs.version}"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Prometheus exporter for opnsense firewall appliances";
    homepage = "https://github.com/AthennaMind/opnsense-exporter";
    changelog = "https://github.com/AthennaMind/opnsense-exporter/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ paepcke ];
    mainProgram = "opnsense-exporter";
  };
})
