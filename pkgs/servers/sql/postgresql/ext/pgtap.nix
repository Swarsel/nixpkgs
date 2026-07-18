{
  lib,
  stdenv,
  fetchFromGitHub,
  perl,
  perlPackages,
  postgresql,
  postgresqlBuildExtension,
  postgresqlTestHook,
  which,
}:

postgresqlBuildExtension (finalAttrs: {
  pname = "pgtap";
  version = "1.3.4";

  src = fetchFromGitHub {
    owner = "theory";
    repo = "pgtap";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SKac6JJmH/z7G1GmQYATMNfywsDIHjNdskzn2MT3kBg=";
  };

  nativeBuildInputs = [
    perl
    perlPackages.TAPParserSourceHandlerpgTAP
    which
  ];

  passthru.tests.extension = stdenv.mkDerivation {
    doCheck = true;

    nativeCheckInputs = [
      postgresqlTestHook
      (postgresql.withPackages (_: [ finalAttrs.finalPackage ]))
    ];

    checkPhase = ''
      runHook preCheck
      sqlPath=$TMPDIR/test.sql
      printf "%s" "$sql" > $sqlPath
      psql -a -v ON_ERROR_STOP=1 -f $sqlPath
      runHook postCheck
    '';

    installPhase = "touch $out";
    __structuredAttrs = true;
    dontUnpack = true;
    name = "pgtap-test";

    sql = ''
      CREATE EXTENSION pgtap;

      BEGIN;
      SELECT plan(1);
      SELECT pass('Test passed');
      SELECT * FROM finish();
      ROLLBACK;
    '';
  };

  meta = {
    inherit (postgresql.meta) platforms;
    description = "Unit testing framework for PostgreSQL";

    longDescription = ''
      pgTAP is a unit testing framework for PostgreSQL written in PL/pgSQL and PL/SQL.
      It includes a comprehensive collection of TAP-emitting assertion functions,
      as well as the ability to integrate with other TAP-emitting test frameworks.
      It can also be used in the xUnit testing style.
    '';

    homepage = "https://pgtap.org";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
