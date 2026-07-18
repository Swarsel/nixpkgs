{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  pkg-config,
  python3,
  vips,
}:

buildNpmPackage rec {
  pname = "btc-rpc-explorer";
  version = "3.5.1";

  src = fetchFromGitHub {
    owner = "janoside";
    repo = "btc-rpc-explorer";
    rev = "v${version}";
    hash = "sha256-L7mW1WIbHga6/UjMx4sP0MUhJIRytUhHVIEWMD2amQo=";
  };

  nativeBuildInputs = [
    pkg-config
    python3
  ];

  buildInputs = [
    vips
  ];

  npmDepsHash = "sha256-eYA2joO4wcV10xJeYLqCbvM2szWlqofmugoHHD9D30U=";
  dontNpmBuild = true;
  makeCacheWritable = true;

  meta = {
    description = "Database-free, self-hosted Bitcoin explorer, via RPC to Bitcoin Core";
    homepage = "https://github.com/janoside/btc-rpc-explorer";
    changelog = "https://github.com/janoside/btc-rpc-explorer/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    mainProgram = "btc-rpc-explorer";
  };
}
