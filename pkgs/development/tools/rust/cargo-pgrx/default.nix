{
  lib,
  fetchCrate,
  openssl,
  pkg-config,
  rustPlatform,
}:

let
  generic =
    {
      cargoHash,
      hash,
      version,
    }:
    rustPlatform.buildRustPackage {
      inherit version;
      inherit cargoHash;
      pname = "cargo-pgrx";

      src = fetchCrate {
        inherit version hash;
        pname = "cargo-pgrx";
      };

      nativeBuildInputs = [
        pkg-config
      ];

      buildInputs = [
        openssl
      ];

      checkFlags = [
        # requires pgrx to be properly initialized with cargo pgrx init
        "--skip=object_utils::tests::parses_managed_postmasters"
        # test name in versions < 0.18
        "--skip=command::schema::tests::test_parse_managed_postmasters"
      ];

      preCheck = ''
        export PGRX_HOME=$(mktemp -d)
      '';

      meta = {
        description = "Build Postgres Extensions with Rust";
        homepage = "https://github.com/pgcentralfoundation/pgrx";
        changelog = "https://github.com/pgcentralfoundation/pgrx/releases/tag/v${version}";
        license = lib.licenses.mit;

        maintainers = with lib.maintainers; [
          happysalada
          matthiasbeyer
        ];

        mainProgram = "cargo-pgrx";
      };
    };
in
{
  # Default version for direct usage.
  # Not to be used with buildPgrxExtension, where it should be pinned.
  # When you make an extension use the latest version, *copy* this to a separate pinned attribute.
  cargo-pgrx = generic {
    version = "0.18.1";
    cargoHash = "sha256-4hQL06ZRykZDeVJMYeBSw50jUPlBVh+J5FfyF1hTlNc=";
    hash = "sha256-4/FKpiMm3MedrmJwXf9NMkzTGQyZuU2GYQ4ZIif3YDE=";
  };
}
// lib.mapAttrs (_: generic) (import ./pinned.nix)
