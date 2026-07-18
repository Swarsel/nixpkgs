{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "tempo";
  version = "3.0.2";

  src = fetchFromGitHub {
    owner = "grafana";
    repo = "tempo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VMgHKeCk82CxbOi6rnt2U25su611wjeZJsRjEZffpiU=";
    fetchSubmodules = true;
  };

  vendorHash = null;
  # tests use docker
  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X=main.Version=${finalAttrs.version}"
    "-X=main.Branch=<release>"
    "-X=main.Revision=${finalAttrs.version}"
  ];

  subPackages = [
    "cmd/tempo-cli"
    "cmd/tempo-query"
    "cmd/tempo-vulture"
    "cmd/tempo"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "High volume, minimal dependency trace storage";
    homepage = "https://grafana.com/oss/tempo/";
    changelog = "https://github.com/grafana/tempo/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.kashw2 ];
  };
})
