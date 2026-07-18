{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nixosTests,
  smartmontools,
}:

buildGoModule (finalAttrs: {
  pname = "smartctl_exporter";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "prometheus-community";
    repo = "smartctl_exporter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9woQgqkPYKMu8p35aeSv3ua1l35BuMzFT4oCVpmyG2E=";
  };

  postPatch = ''
    substituteInPlace main.go README.md \
      --replace-fail /usr/sbin/smartctl ${lib.getExe smartmontools}
  '';

  vendorHash = "sha256-bDO7EgCjmObNaYHllczDKuFyKTKH0iCFDSLke6VMsHI=";

  ldflags = [
    "-X github.com/prometheus/common/version.Version=${finalAttrs.version}"
  ];

  passthru.tests = { inherit (nixosTests.prometheus-exporters) smartctl; };

  meta = {
    description = "Export smartctl statistics for Prometheus";
    homepage = "https://github.com/prometheus-community/smartctl_exporter";
    license = lib.licenses.lgpl3;

    maintainers = with lib.maintainers; [
      hexa
      Frostman
    ];

    platforms = lib.platforms.linux;
    mainProgram = "smartctl_exporter";
  };
})
