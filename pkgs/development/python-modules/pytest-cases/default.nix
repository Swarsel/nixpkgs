{
  lib,
  buildPythonPackage,
  decopatch,
  fetchPypi,
  makefun,
  packaging,
  pytest,
  setuptools-scm,
  setuptools_80,
}:

buildPythonPackage rec {
  pname = "pytest-cases";
  version = "3.9.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-xOGB8bUlyTGjGNSBL6jeZWwsj7d/zPFXHs8Mxf6Of48=";
    pname = "pytest_cases";
  };

  # Tests have dependencies (pytest-harvest, pytest-steps) which
  # are not available in Nixpkgs. Most of the packages (decopatch,
  # makefun, pytest-*) have circular dependencies.
  doCheck = false;

  build-system = [
    setuptools_80
    setuptools-scm
  ];

  dependencies = [
    decopatch
    makefun
    packaging
    pytest
  ];

  pyproject = true;
  pythonImportsCheck = [ "pytest_cases" ];

  meta = {
    description = "Separate test code from test cases in pytest";
    homepage = "https://github.com/smarie/python-pytest-cases";
    changelog = "https://github.com/smarie/python-pytest-cases/releases/tag/${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fab ];
  };
}
