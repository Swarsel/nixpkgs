{
  lib,
  fetchFromGitHub,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage {
  pname = "synapse-bt";
  version = "unstable-2023-02-16";

  src = fetchFromGitHub {
    owner = "Luminarys";
    repo = "synapse";
    rev = "2165fe22589d7255e497d196c1d42b4c2ace1408";
    hash = "sha256-2irXNgEK9BjRuNu3DUMElmf2vIpGzwoFneAEe97GRh4=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-ebqUH01h4B3Aq3apSKpae8ncaFirbrZiDxjiQM9kzg4=";
  cargoBuildFlags = [ "--all" ];

  meta = {
    description = "Flexible and fast BitTorrent daemon";
    homepage = "https://synapse-bt.org/";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ dywedir ];
  };
}
