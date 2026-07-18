{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  matplotlib,
  numpy,
  numpydoc,
  pytest,
  pytestCheckHook,
  scipy,
}:

buildPythonPackage rec {
  pname = "allantools";
  version = "2024.06";

  src = fetchFromGitHub {
    owner = "aewallin";
    repo = "allantools";
    tag = version;
    hash = "sha256-dF19aSpIioOm0BnwrLkMe/DtfgWSKFnX4c/Xs1O2Quw=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    hatchling
  ];

  dependencies = [
    matplotlib
    numpy
    numpydoc
    pytest
    scipy
  ];

  pyproject = true;

  pythonImportsCheck = [
    "allantools"
  ];

  meta = {
    description = "Allan deviation and related time & frequency statistics library in Python";
    homepage = "https://github.com/aewallin/allantools";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ kiranshila ];
  };
}
