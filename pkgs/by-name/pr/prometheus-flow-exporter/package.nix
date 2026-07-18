{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule rec {
  pname = "flow-exporter";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "neptune-networks";
    repo = "flow-exporter";
    rev = "v${version}";
    sha256 = "sha256-6FqupoYWRvex7XhM7ly8f7ICnuS9JvCRIVEBIJe+64k=";
  };

  vendorHash = "sha256-2raOUOPiMUMydIsfSsnwUAAiM7WyMio1NgL1EoADr2s=";

  meta = {
    description = "Export network flows from kafka to Prometheus";
    homepage = "https://github.com/neptune-networks/flow-exporter";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kloenk ];
    platforms = lib.platforms.linux;
    mainProgram = "flow-exporter";
  };
}
