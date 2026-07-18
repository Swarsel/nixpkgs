{
  lib,
  fetchFromGitHub,
  biocutils,
  buildPythonPackage,
  numpy,
  pandas,
  polars,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "biocframe";
  version = "0.7.3";

  src = fetchFromGitHub {
    owner = "BiocPy";
    repo = "BiocFrame";
    tag = version;
    hash = "sha256-NycHzlOdDRyXvpZLWDr7mg5eXxrBjsSk16AUHpQrDN0=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
    pandas
    polars
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    biocutils
    numpy
  ];

  pyproject = true;
  pythonImportsCheck = [ "biocframe" ];

  meta = {
    description = "Bioconductor-like data frames";
    homepage = "https://github.com/BiocPy/BiocFrame";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ b-rodrigues ];
  };
}
