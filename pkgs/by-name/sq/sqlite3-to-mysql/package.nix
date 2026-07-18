{
  lib,
  fetchFromGitHub,
  mysql84,
  nixosTests,
  python3Packages,
  sqlite3-to-mysql,
  testers,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "sqlite3-to-mysql";
  version = "2.5.6";

  src = fetchFromGitHub {
    owner = "techouse";
    repo = "sqlite3-to-mysql";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6WIGQVZZBWVGP8nr7Gxvd3j9wrt08EcCmb9ljRMkUgc=";
  };

  # tests require a mysql server instance
  doCheck = false;

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies = with python3Packages; [
    click
    mysql-connector-python
    pytimeparse2
    pymysql
    pymysqlsa
    simplejson
    sqlalchemy
    sqlalchemy-utils
    tqdm
    tabulate
    unidecode
    packaging
    mysql84
    python-dateutil
    sqlglot
  ];

  pyproject = true;

  pythonRelaxDeps = [
    "mysql-connector-python"
  ];

  # run package tests as a separate nixos test
  passthru.tests = {
    version = testers.testVersion {
      command = "sqlite3mysql --version";
      package = sqlite3-to-mysql;
    };

    nixosTest = nixosTests.sqlite3-to-mysql;
  };

  meta = {
    description = "Simple Python tool to transfer data from SQLite 3 to MySQL";
    homepage = "https://github.com/techouse/sqlite3-to-mysql";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ gador ];
    mainProgram = "sqlite3mysql";
  };
})
