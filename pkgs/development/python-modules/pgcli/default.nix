{
  lib,
  stdenv,
  buildPythonPackage,
  cli-helpers,
  click,
  configobj,
  fetchPypi,
  keyring,
  mock,
  pendulum,
  pgspecial,
  prompt-toolkit,
  psycopg,
  pygments,
  pytestCheckHook,
  setproctitle,
  setuptools,
  setuptools-scm,
  sqlparse,
  sshtunnel,
  tzlocal,
}:

# this is a pythonPackage because of the ipython line magics in pgcli.magic
# integrating with ipython-sql
buildPythonPackage rec {
  pname = "pgcli";
  version = "4.5.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-nc4H9bYoBoFWJWy4GOUZGnc6/m7rcFTyEPqJKBNiXj4=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    mock
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    cli-helpers
    click
    configobj
    prompt-toolkit
    psycopg
    pygments
    sqlparse
    pgspecial
    setproctitle
    keyring
    pendulum
    sshtunnel
    tzlocal
  ];

  disabledTests = [
    # requires running postgres and postgresqlTestHook does not work
    "test_application_name_in_env"
    "test_init_command_option"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ "test_application_name_db_uri" ];

  pyproject = true;
  pythonRelaxDeps = [ "click" ];

  meta = {
    description = "Command-line interface for PostgreSQL";

    longDescription = ''
      Rich command-line interface for PostgreSQL with auto-completion and
      syntax highlighting.
    '';

    homepage = "https://pgcli.com";
    changelog = "https://github.com/dbcli/pgcli/raw/v${version}/changelog.rst";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      SuperSandro2000
    ];

    mainProgram = "pgcli";
  };
}
