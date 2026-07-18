{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "sciform";
  version = "0.39.1";

  src = fetchFromGitHub {
    owner = "jagerber48";
    repo = "sciform";
    tag = version;
    hash = "sha256-t43v3xnZap6NayzqBVvw2PzPzHZ5QPSEO5aRzS8AKKE=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  pyproject = true;

  pythonImportsCheck = [
    "sciform"
  ];

  meta = {
    description = "Package for formatting numbers into scientific formatted strings";
    homepage = "https://sciform.readthedocs.io/en/stable/";
    changelog = "https://github.com/jagerber48/sciform/blob/${src.tag}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ doronbehar ];
    downloadPage = "https://github.com/jagerber48/sciform";
  };
}
