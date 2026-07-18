{
  lib,
  fetchFromGitHub,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage {
  pname = "gridlock";
  version = "0-unstable-2023-08-29";

  src = fetchFromGitHub {
    owner = "lf-";
    repo = "gridlock";
    rev = "a98abfa554e5f8e2b7242662c0c714b7f1d7ec29";
    hash = "sha256-I4NGfgNX79ZhWXDeUDJyDzP2GxcNhHhazVmmmPlz5js=";
  };

  outputs = [
    "out"
    "nyarr"
  ];

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-CflDi1sjPBX+FOj74DWYKcg0O8Q7bnCFhzEnCrRi0g8=";

  postInstall = ''
    moveToOutput bin/nyarr $nyarr
  '';

  meta = {
    description = "Nix compatible lockfile manager, without Nix";
    homepage = "https://github.com/lf-/gridlock";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
