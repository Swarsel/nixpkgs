{
  lib,
  fetchFromGitHub,
  openssl,
  pkg-config,
  rustPlatform,
}:

let
  version = "0.4.3";
in
rustPlatform.buildRustPackage rec {
  inherit version;
  pname = "schemamap";

  src = fetchFromGitHub {
    owner = "schemamap";
    repo = "schemamap";
    rev = "v${version}";
    hash = "sha256-YR7Ucd8/Z1hOUNokmfSVP2ZxDL7qLb6SZ86/S7V/GKk=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-8UmLAT7Etb9MARoGhvOHPhkdR/8jCEAjAK/mWRHL9hk=";
  sourceRoot = "${src.name}/rust";

  meta = {
    description = "Instant batch data import for Postgres";
    homepage = "https://schemamap.io";
    changelog = "https://github.com/schemamap/schemamap/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ thenonameguy ];
    mainProgram = "schemamap";
  };
}
