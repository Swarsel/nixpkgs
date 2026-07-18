{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "grafana-dash-n-grab";
  version = "0.9.3";

  src = fetchFromGitHub {
    owner = "esnet";
    repo = "gdg";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-K8/NhTFfYk9oL2wpRxFLobEx3aW6fx7PzLxf5wFNbFY=";
  };

  vendorHash = "sha256-8ZIu9U6OFRD4pu8K/AUBesX/SRyMkOKi8cdScHBdKnk=";
  # The test suite tries to communicate with a running version of grafana locally. This fails if
  # you don't have grafana running.
  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
    "-X github.com/esnet/gdg/version.GitCommit=${finalAttrs.src.rev}"
  ];

  meta = {
    description = "Grafana Dash-n-Grab (gdg) -- backup and restore Grafana dashboards, datasources, and other entities";
    homepage = "https://github.com/esnet/gdg";
    changelog = "https://github.com/esnet/gdg/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      cdepillabout
      wraithm
    ];

    mainProgram = "gdg";
  };
})
