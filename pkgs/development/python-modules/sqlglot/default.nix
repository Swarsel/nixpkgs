{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  duckdb,
  numpy,
  pandas,
  # tests
  pytestCheckHook,
  # dependencies
  python-dateutil,
  # build-system
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "sqlglot";
  version = "28.9.0";

  src = fetchFromGitHub {
    owner = "tobymao";
    repo = "sqlglot";
    tag = "v${version}";
    hash = "sha256-2AmHKGAoDF8w9k8VN9d25Js3UiSh8YNqdGRHN7VqRpw=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    duckdb
    numpy
    pandas
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    # Optional dependency used in the sqlglot optimizer
    python-dateutil
  ];

  pyproject = true;
  pythonImportsCheck = [ "sqlglot" ];

  meta = {
    description = "No dependency Python SQL parser, transpiler, and optimizer";
    homepage = "https://github.com/tobymao/sqlglot";
    changelog = "https://github.com/tobymao/sqlglot/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ cpcloud ];
  };
}
