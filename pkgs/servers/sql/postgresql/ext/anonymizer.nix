{
  lib,
  buildPgrxExtension,
  cargo-pgrx_0_16_0,
  jitSupport,
  nixosTests,
  pg-dump-anon,
  postgresql,
  runtimeShell,
}:

buildPgrxExtension {
  inherit (pg-dump-anon) version src;
  inherit postgresql;
  pname = "postgresql_anonymizer";
  cargoHash = "sha256-Z1uH6Z2qLV1Axr8dXqPznuEZcacAZnv11tb3lWBh1yw=";
  # Tries to copy extension into postgresql's store path.
  doCheck = false;
  cargo-pgrx = cargo-pgrx_0_16_0;
  passthru.tests = nixosTests.postgresql.anonymizer.passthru.override postgresql;

  meta = {
    inherit (pg-dump-anon.meta) homepage maintainers license;
    description = "Extension to mask or replace personally identifiable information (PII) or commercially sensitive data from a PostgreSQL database";
  };
}
