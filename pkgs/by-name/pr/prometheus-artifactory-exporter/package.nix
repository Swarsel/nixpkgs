{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nixosTests,
}:

buildGoModule rec {
  pname = "artifactory_exporter";
  version = "1.16.1";

  src = fetchFromGitHub {
    owner = "peimanja";
    repo = "artifactory_exporter";
    rev = rev;
    hash = "sha256-ffICacOaYD3/wB38qQ/qYOfDwQxe1tndRdR2BHxolcA=";
  };

  vendorHash = "sha256-zTuqSPjKJng7Gf/RHo4KYpSzlGRrOVa/AEpz7ZDePyc=";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/prometheus/common/version.Version=${version}"
    "-X github.com/prometheus/common/version.Revision=${rev}"
    "-X github.com/prometheus/common/version.Branch=master"
    "-X github.com/prometheus/common/version.BuildDate=19700101-00:00:00"
  ];

  rev = "v${version}";
  subPackages = [ "." ];
  passthru.tests = { inherit (nixosTests.prometheus-exporters) artifactory; };

  meta = {
    description = "JFrog Artifactory Prometheus Exporter";
    homepage = "https://github.com/peimanja/artifactory_exporter";
    changelog = "https://github.com/peimanja/artifactory_exporter/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ lbpdt ];
    mainProgram = "artifactory_exporter";
  };
}
