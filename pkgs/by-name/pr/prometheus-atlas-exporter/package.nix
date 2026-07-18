{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule rec {
  pname = "atlas-exporter";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "czerwonk";
    repo = "atlas_exporter";
    rev = version;
    sha256 = "sha256-vhUhWO7fQpUHT5nyxbT8AylgUqDNZRSb+EGRNGZJ14E=";
  };

  vendorHash = "sha256-tR+OHxj/97AixuAp0Kx9xQsKPAxpvF6hDha5BgMBha0=";

  meta = {
    description = "Prometheus exporter for RIPE Atlas measurement results";
    homepage = "https://github.com/czerwonk/atlas_exporter";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ clerie ];
    mainProgram = "atlas_exporter";
  };
}
