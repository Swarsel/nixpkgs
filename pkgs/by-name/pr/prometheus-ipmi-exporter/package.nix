{
  lib,
  fetchFromGitHub,
  buildGoModule,
  freeipmi,
  makeWrapper,
  nixosTests,
}:

buildGoModule rec {
  pname = "ipmi_exporter";
  version = "1.10.1";

  src = fetchFromGitHub {
    owner = "prometheus-community";
    repo = "ipmi_exporter";
    rev = "v${version}";
    hash = "sha256-U4vkOKxHKJyfsngn2JqZncq71BohBnGM7Z1hA79YhKA=";
  };

  nativeBuildInputs = [ makeWrapper ];
  vendorHash = "sha256-8ebarbsaHiufPEghgOlaRMouGdI1c1Yo8pjqG2bPdK8=";

  postInstall = ''
    wrapProgram $out/bin/ipmi_exporter --prefix PATH : ${lib.makeBinPath [ freeipmi ]}
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/prometheus/common/version.Version=${version}"
    "-X github.com/prometheus/common/version.Revision=0000000"
    "-X github.com/prometheus/common/version.Branch=unknown"
    "-X github.com/prometheus/common/version.BuildUser=nix@nixpkgs"
    "-X github.com/prometheus/common/version.BuildDate=unknown"
  ];

  passthru.tests = { inherit (nixosTests.prometheus-exporters) ipmi; };

  meta = {
    description = "IPMI exporter for Prometheus";
    homepage = "https://github.com/prometheus-community/ipmi_exporter";
    changelog = "https://github.com/prometheus-community/ipmi_exporter/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ snaar ];
    mainProgram = "ipmi_exporter";
  };
}
