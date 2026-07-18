{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "quantities";
  version = "0.16.4";

  src = fetchFromGitHub {
    owner = "python-quantities";
    repo = "python-quantities";
    tag = "v${version}";
    hash = "sha256-a+UtNvcnQr4z87tpidx99u46M2H+EKtQ1EzIG5zQnmI=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [ numpy ];
  pyproject = true;
  pythonImportsCheck = [ "quantities" ];

  meta = {
    description = "Quantities is designed to handle arithmetic and conversions of physical quantities";
    homepage = "https://python-quantities.readthedocs.io/";
    changelog = "https://github.com/python-quantities/python-quantities/blob/v${version}/CHANGES.txt";
    license = lib.licenses.bsd2;
    maintainers = [ ];
  };
}
