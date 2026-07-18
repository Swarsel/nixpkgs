{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  pytestCheckHook,
  setuptools,
  torch,
}:

buildPythonPackage (finalAttrs: {
  pname = "roma";
  version = "1.5.6";

  src = fetchFromGitHub {
    owner = "naver";
    repo = "roma";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ssfgEz2z9IxZpjaQTySXXZ1BSRpnlCcQG2pm/Q3G514=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    numpy
    torch
  ];

  pyproject = true;

  pythonImportsCheck = [
    "roma"
  ];

  meta = {
    description = "Lightweight library to deal with 3D rotations in PyTorch";
    homepage = "https://github.com/naver/roma";
    changelog = "https://naver.github.io/roma/#changelog";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ nim65s ];
  };
})
