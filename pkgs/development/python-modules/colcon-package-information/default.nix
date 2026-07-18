{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  colcon,
  packaging,
  pytest-cov-stub,
  pytestCheckHook,
  scspell,
  setuptools,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "colcon-package-information";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "colcon";
    repo = "colcon-package-information";
    tag = version;
    hash = "sha256-1l2c1f0Ppp7EqOtIdaTFpwY74J6OLTg2gK7bbeYmZ5Y=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
    scspell
    writableTmpDirAsHomeHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    colcon
    packaging
  ];

  disabledTestPaths = [
    "test/test_flake8.py"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "colcon_package_information"
  ];

  meta = {
    description = "Extension for colcon-core to output package information";
    homepage = "http://colcon.readthedocs.io/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ guelakais ];
  };
}
