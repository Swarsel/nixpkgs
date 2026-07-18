{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  pyparsing,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "periodictable";
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "python-periodictable";
    repo = "periodictable";
    tag = "v${version}";
    hash = "sha256-nI6hiLnqmVXT06pPkHCBEMTxZhfnZJqSImW3V9mJ4+8=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    numpy
    pyparsing
  ];

  pyproject = true;
  pythonImportsCheck = [ "periodictable" ];

  meta = {
    description = "Extensible periodic table of the elements";
    homepage = "https://github.com/pkienzle/periodictable";
    license = lib.licenses.publicDomain;
    maintainers = with lib.maintainers; [ rprospero ];
  };
}
