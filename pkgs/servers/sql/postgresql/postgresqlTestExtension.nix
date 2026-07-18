{
  lib,
  postgresql,
  postgresqlTestHook,
  stdenvNoCC,
}:

{
  finalPackage,
  sql,
  asserts ? [ ],
  withPackages ? [ ],
  ...
}@extraArgs:
stdenvNoCC.mkDerivation (
  {
    doCheck = true;

    nativeCheckInputs = [
      postgresqlTestHook
      (postgresql.withPackages (ps: [ finalPackage ] ++ (map (p: ps."${p}") withPackages)))
    ];

    checkPhase = ''
      runHook preCheck
      sqlPath=$TMPDIR/test.sql
      printf "%s" "$sql" > $sqlPath
      psql -a -v ON_ERROR_STOP=1 -f "$sqlPath"
      runHook postCheck
    '';

    installPhase = "touch $out";
    __structuredAttrs = true;
    dontUnpack = true;
    name = "${finalPackage.name}-test-extension";
    postgresqlTestUserOptions = "LOGIN SUPERUSER";

    sql =
      sql
      + lib.concatMapStrings (
        {
          description,
          expected,
          query,
        }:
        ''
          DO $$ BEGIN
            ASSERT (${query}) = (${expected}), '${lib.replaceStrings [ "'" ] [ "''" ] description}';
          END $$;
        ''
      ) asserts;
  }
  // lib.removeAttrs extraArgs [
    "asserts"
    "finalPackage"
    "sql"
    "withPackages"
  ]
)
