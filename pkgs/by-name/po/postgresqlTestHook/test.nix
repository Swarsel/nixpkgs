{
  stdenv,
  postgresql,
  postgresqlTestHook,
}:

stdenv.mkDerivation {
  buildInputs = [ postgresqlTestHook ];
  doCheck = true;
  nativeCheckInputs = [ postgresql ];

  checkPhase = ''
    runHook preCheck
    sqlPath=$TMPDIR/test.sql
    printf "%s" "$sql" > $sqlPath
    psql <$sqlPath | grep 'it worked'
    TEST_RAN=1
    runHook postCheck
  '';

  installPhase = ''
    [[ $TEST_RAN == 1 && $TEST_POST_HOOK_RAN == 1 ]]
    touch $out
  '';

  __structuredAttrs = true;
  dontUnpack = true;
  name = "postgresql-test-hook-test";

  postgresqlTestSetupPost = ''
    TEST_POST_HOOK_RAN=1
  '';

  sql = ''
    CREATE TABLE hello (
      message text
    );
    INSERT INTO hello VALUES ('it '||'worked');
    SELECT * FROM hello;
  '';
}
