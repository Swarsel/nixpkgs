{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  pandas,
  pytest-cov-stub,
  pytestCheckHook,
  scipy,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "biocutils";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "BiocPy";
    repo = "BiocUtils";
    tag = version;
    hash = "sha256-CKIAJsWw9zCjhIpZpgFgakvszjO+1lZS8535LMfEH2Y=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
    pandas
    scipy
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [ numpy ];
  pyproject = true;
  pythonImportsCheck = [ "biocutils" ];

  meta = {
    description = "Miscellaneous utilities for BiocPy, mostly to mimic base functionality in R";
    homepage = "https://github.com/BiocPy/BiocUtils";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ b-rodrigues ];
  };
}
