{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule (finalAttrs: {
  pname = "pmtiles";
  version = "1.31.0";

  src = fetchFromGitHub {
    owner = "protomaps";
    repo = "go-pmtiles";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OWf66RsOvYoJEsDI4rVsimX60uxuZoqTgIwAI7kxvs0=";
  };

  vendorHash = "sha256-0u/04mpqhpRideIf8eOzgC7ZWNp4P2c2ssQvyWlcD4M=";

  postInstall = ''
    mv $out/bin/go-pmtiles $out/bin/pmtiles
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
    "-X main.commit=v${finalAttrs.version}"
  ];

  meta = {
    description = "Single-file utility for creating and working with PMTiles archives";
    homepage = "https://github.com/protomaps/go-pmtiles";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ theaninova ];
    mainProgram = "pmtiles";
    teams = [ lib.teams.geospatial ];
  };
})
