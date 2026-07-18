{
  lib,
  aiosqlite,
  alembic,
  buildPythonPackage,
  debtcollector,
  fetchPypi,
  oslo-config,
  oslo-context,
  oslo-i18n,
  oslo-utils,
  oslotest,
  pbr,
  psycopg2,
  setuptools,
  sqlalchemy,
  stestr,
  stevedore,
  testresources,
  testscenarios,
}:

buildPythonPackage rec {
  pname = "oslo-db";
  version = "18.1.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-B16GziPAwh2x01CR8dyyGwVEnInDpDJtpPLT+4MwIj8=";
    pname = "oslo_db";
  };

  nativeCheckInputs = [
    aiosqlite
    oslo-context
    oslotest
    stestr
    psycopg2
    testresources
    testscenarios
  ];

  checkPhase = ''
    runHook preCheck
    stestr run -e <(echo "oslo_db.tests.sqlalchemy.test_utils.TestModelQuery.test_project_filter_allow_none")
    runHook postCheck
  '';

  build-system = [
    pbr
    setuptools
  ];

  dependencies = [
    alembic
    debtcollector
    oslo-config
    oslo-i18n
    oslo-utils
    sqlalchemy
    stevedore
  ]
  ++ sqlalchemy.optional-dependencies.asyncio;

  pyproject = true;
  pythonImportsCheck = [ "oslo_db" ];

  meta = {
    description = "Oslo Database library";
    homepage = "https://github.com/openstack/oslo.db";
    license = lib.licenses.asl20;
    teams = [ lib.teams.openstack ];
  };
}
