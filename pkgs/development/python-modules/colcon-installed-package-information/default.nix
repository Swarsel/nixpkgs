{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  colcon,
  importlib-metadata,
  pytest-cov-stub,
  # tests
  pytestCheckHook,
  scspell,
  # build-system
  setuptools,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "colcon-installed-package-information";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "colcon";
    repo = "colcon-installed-package-information";
    tag = version;
    hash = "sha256-7PjLWLwX5QwxWCN1iWOGB3cyArjnxQKT5BHmukj0MII=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
    scspell
    writableTmpDirAsHomeHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    colcon
    importlib-metadata
  ];

  disabledTestPaths = [
    # Skip the linter tests that require additional dependencies
    "test/test_flake8.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "colcon_installed_package_information" ];

  meta = {
    description = "Extensions for colcon to inspect packages which have already been installed";
    homepage = "https://colcon.readthedocs.io/en/released/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ guelakais ];
    downloadPage = "https://github.com/colcon/colcon-installed-package-information";
  };
}
