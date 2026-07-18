{
  lib,
  fetchFromGitHub,
  buildGoModule,
  geos,
  leveldb,
}:

buildGoModule (finalAttrs: {
  pname = "imposm";
  version = "0.14.2";

  src = fetchFromGitHub {
    owner = "omniscale";
    repo = "imposm3";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Bl6LSF/aN/c0lH93fxm2HGvxs7Grv4qJc/iN04AlQP0=";
  };

  buildInputs = [
    leveldb
    geos
  ];

  vendorHash = null;
  # requires network access
  doCheck = false;

  ldflags = [
    "-s -w"
    "-X github.com/omniscale/imposm3.Version=${finalAttrs.version}"
  ];

  meta = {
    description = "Imports OpenStreetMap data into PostGIS";
    homepage = "https://imposm.org/";
    changelog = "https://github.com/omniscale/imposm3/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.apsl20;
    maintainers = with lib.maintainers; [ sikmir ];
    mainProgram = "imposm";
  };
})
