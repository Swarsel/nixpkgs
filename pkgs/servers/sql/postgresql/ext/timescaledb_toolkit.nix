{
  lib,
  fetchFromGitHub,
  buildPgrxExtension,
  cargo-pgrx_0_18_0,
  nix-update-script,
  postgresql,
}:

buildPgrxExtension (finalAttrs: {
  inherit postgresql;
  pname = "timescaledb_toolkit";
  version = "1.23.0";

  src = fetchFromGitHub {
    owner = "timescale";
    repo = "timescaledb-toolkit";
    tag = finalAttrs.version;
    hash = "sha256-we2w2rYGRC9Did9oocgCWbIUxb8a/g0BlCHXQUe1f8I=";
  };

  cargoHash = "sha256-R6daWAQssopVps+IqF94dGBcZMC/u1J4eEg6WouAwOo=";
  # tests take really long
  doCheck = false;

  postInstall = ''
    cargo run --manifest-path ./tools/post-install/Cargo.toml -- --dir "$out"
  '';

  buildAndTestSubdir = "extension";
  cargo-pgrx = cargo-pgrx_0_18_0;

  passthru = {
    tests = postgresql.pkgs.timescaledb.tests;
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Provide additional tools to ease all things analytic when using TimescaleDB";
    homepage = "https://github.com/timescale/timescaledb-toolkit";
    license = lib.licenses.tsl;
    maintainers = with lib.maintainers; [ typetetris ];
    platforms = postgresql.meta.platforms;

    broken =
      lib.versionOlder postgresql.version "15"
      ||
        # Check after next package update.
        lib.warnIf (finalAttrs.version != "1.23.0")
          "Is postgresql19Packages.timescaledb_toolkit still broken?"
          (lib.versionAtLeast postgresql.version "19");
  };
})
