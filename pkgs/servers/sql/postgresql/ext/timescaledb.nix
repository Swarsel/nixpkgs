{
  lib,
  fetchFromGitHub,
  cmake,
  libkrb5,
  openssl,
  postgresql,
  postgresqlBuildExtension,
  postgresqlTestExtension,
  enableUnfree ? true,
}:

postgresqlBuildExtension (finalAttrs: {
  pname = "timescaledb${lib.optionalString (!enableUnfree) "-apache"}";
  version = "2.28.2";

  src = fetchFromGitHub {
    owner = "timescale";
    repo = "timescaledb";
    tag = finalAttrs.version;
    hash = "sha256-oEH6h3OGwdDYIKAtwWpVgIQJdB+IJhN2U/WJu9aHlbQ=";
  };

  # Fix the install phase which tries to install into the pgsql extension dir,
  # and cannot be manually overridden. This is rather fragile but works OK.
  postPatch = ''
    for x in CMakeLists.txt sql/CMakeLists.txt; do
      substituteInPlace "$x" \
        --replace-fail 'DESTINATION "''${PG_SHAREDIR}/extension"' "DESTINATION \"$out/share/postgresql/extension\""
    done

    for x in src/CMakeLists.txt src/loader/CMakeLists.txt tsl/src/CMakeLists.txt; do
      substituteInPlace "$x" \
        --replace-fail 'DESTINATION ''${PG_PKGLIBDIR}' "DESTINATION \"$out/lib\""
    done
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    openssl
    libkrb5
  ];

  cmakeFlags = [
    (lib.cmakeBool "SEND_TELEMETRY_DEFAULT" false)
    (lib.cmakeBool "REGRESS_CHECKS" false)
    (lib.cmakeBool "TAP_CHECKS" false)
    (lib.cmakeBool "APACHE_ONLY" (!enableUnfree))
  ];

  passthru.tests.extension = postgresqlTestExtension {
    inherit (finalAttrs) finalPackage;

    asserts = [
      {
        description = "hypertable can be queried successfully.";
        expected = "5";
        query = "SELECT count(*) FROM sth";
      }
    ];

    postgresqlExtraSettings = ''
      shared_preload_libraries='timescaledb'
    '';

    sql = ''
      CREATE EXTENSION timescaledb;
      CREATE EXTENSION timescaledb_toolkit;

      CREATE TABLE sth (
        time TIMESTAMPTZ NOT NULL,
        value DOUBLE PRECISION
      );

      SELECT create_hypertable('sth', 'time');

      INSERT INTO sth (time, value) VALUES
      ('2003-04-12 04:05:06 America/New_York', 1.0),
      ('2003-04-12 04:05:07 America/New_York', 2.0),
      ('2003-04-12 04:05:08 America/New_York', 3.0),
      ('2003-04-12 04:05:09 America/New_York', 4.0),
      ('2003-04-12 04:05:10 America/New_York', 5.0)
      ;

      WITH t AS (
        SELECT
          time_bucket('1 day'::interval, time) AS dt,
          stats_agg(value) AS stats
        FROM sth
        GROUP BY time_bucket('1 day'::interval, time)
      )
      SELECT
        average(stats)
      FROM t;
    '';

    withPackages = [ "timescaledb_toolkit" ];
  };

  meta = {
    description = "Scales PostgreSQL for time-series data via automatic partitioning across time and space";
    homepage = "https://www.timescale.com/";
    changelog = "https://github.com/timescale/timescaledb/blob/${finalAttrs.version}/CHANGELOG.md";
    license = with lib.licenses; if enableUnfree then tsl else asl20;
    maintainers = with lib.maintainers; [ kirillrdy ];
    platforms = postgresql.meta.platforms;

    broken =
      lib.versionOlder postgresql.version "15"
      ||
        # Check after next package update.
        lib.warnIf (finalAttrs.version != "2.28.2") "Is postgresql19Packages.timescaledb still broken?" (
          lib.versionAtLeast postgresql.version "19"
        );
  };
})
