{
  lib,
  fetchFromGitHub,
  bleach,
  buildPythonPackage,
  lxml,
  mt-940,
  pytest-mock,
  pytestCheckHook,
  requests,
  sepaxml,
  setuptools,
}:

buildPythonPackage rec {
  pname = "fints";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "raphaelm";
    repo = "python-fints";
    tag = "v${version}";
    hash = "sha256-ll2+PtcGQiY5nbQTKVetd2ecDBVSXgzWP4Vzzri1Trs=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-mock
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    bleach
    lxml
    mt-940
    requests
    sepaxml
  ];

  pyproject = true;
  pythonImportsCheck = [ "fints" ];
  pythonRelaxDeps = [ "lxml" ];
  pythonRemoveDeps = [ "enum-tools" ];

  meta = {
    description = "Pure-python FinTS (formerly known as HBCI) implementation";
    homepage = "https://github.com/raphaelm/python-fints/";
    license = lib.licenses.lgpl3Only;

    maintainers = with lib.maintainers; [
      dotlambda
    ];
  };
}
