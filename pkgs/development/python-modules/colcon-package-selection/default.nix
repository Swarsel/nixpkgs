{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  colcon,
  pytest-cov-stub,
  pytestCheckHook,
  scspell,
  setuptools,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "colcon-package-selection";
  version = "0.2.10";

  src = fetchFromGitHub {
    owner = "colcon";
    repo = "colcon-package-selection";
    tag = version;
    hash = "sha256-27Kk1l/Zvc18d4EfFPdUR/yeCS9fU1VJuHglyjPwnh0=";
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
  ];

  disabledTestPaths = [
    "test/test_flake8.py"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "colcon_package_selection"
  ];

  meta = {
    description = "Extension for colcon to select the packages to process";
    homepage = "http://colcon.readthedocs.io/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ guelakais ];
    downloadPage = "https://github.com/colcon/colcon-package-selection";
  };
}
