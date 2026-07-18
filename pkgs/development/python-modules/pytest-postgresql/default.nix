{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  mirakuru,
  packaging,
  port-for,
  postgresql,
  psycopg,
  pytest,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pytest-postgresql";
  version = "7.0.2";

  src = fetchFromGitHub {
    owner = "dbfixtures";
    repo = "pytest-postgresql";
    tag = "v${version}";
    hash = "sha256-/EekUveW3wb8NlcKacMJpjjU7bpFvnNMpAuZ9h0sbpw=";
  };

  postPatch = ''
    sed -i 's#/usr/lib/postgresql/.*/bin/pg_ctl#${postgresql}/bin/pg_ctl#' pytest_postgresql/plugin.py
  '';

  buildInputs = [ pytest ];
  # Can't reliably run checkPhase on darwin because of nix bug, see:
  #  https://github.com/NixOS/nixpkgs/issues/371242
  doCheck = !stdenv.buildPlatform.isDarwin;

  nativeCheckInputs = [
    postgresql
    pytestCheckHook
    pytest-cov-stub
  ];

  build-system = [ setuptools ];

  dependencies = [
    mirakuru
    port-for
    psycopg
    packaging
  ];

  disabledTestPaths = [ "tests/docker/test_noproc_docker.py" ]; # requires Docker

  disabledTests = [
    # "ValueError: Pytest terminal summary report not found"
    "test_postgres_drop_test_database"
    "test_postgres_loader_in_cli"
    "test_postgres_loader_in_ini"
    "test_postgres_options_config_in_cli"
    "test_postgres_options_config_in_ini"
    "test_postgres_port_search_count_in_cli_is_int"
    "test_postgres_port_search_count_in_ini_is_int"
  ];

  pyproject = true;

  pytestFlags = [
    "-pno:postgresql"
  ];

  pythonImportsCheck = [
    "pytest_postgresql"
    "pytest_postgresql.executor"
  ];

  meta = {
    description = "Pytest plugin that enables you to test code on a temporary PostgreSQL database";
    homepage = "https://pypi.org/project/pytest-postgresql/";
    changelog = "https://github.com/dbfixtures/pytest-postgresql/blob/v${version}/CHANGES.rst";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
}
