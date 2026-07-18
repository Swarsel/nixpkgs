{
  lib,
  fetchFromGitHub,
  crystal,
}:

crystal.buildCrystalPackage rec {
  pname = "shards";
  version = "0.19.1";

  src = fetchFromGitHub {
    owner = "crystal-lang";
    repo = "shards";
    tag = "v${version}";
    hash = "sha256-LOdI389nVsFXkKPKco1C+O710kBlWImzCvdBBYEsWQQ=";
  };

  # tries to execute git which fails spectacularly
  doCheck = false;
  crystalBinaries.shards.src = "./src/shards.cr";
  # we cannot use `make` or `shards` here as it would introduce a cyclical dependency
  format = "crystal";
  shardsFile = ./shards.nix;

  meta = {
    inherit (crystal.meta) homepage platforms;
    description = "Dependency manager for the Crystal language";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ peterhoeg ];
    mainProgram = "shards";
  };
}
