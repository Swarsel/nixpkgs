{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pyparsing,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyclibrary";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "MatthieuDartiailh";
    repo = "pyclibrary";
    tag = finalAttrs.version;
    hash = "sha256-RyIbRySRWSZwKP5G6yXYCOnfKOV0165aPyjMf3nSbOM=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    pyparsing
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyclibrary" ];

  meta = {
    description = "C parser and ctypes automation for python";
    homepage = "https://github.com/MatthieuDartiailh/pyclibrary";
    changelog = "https://github.com/MatthieuDartiailh/pyclibrary/blob/${finalAttrs.src.tag}/CHANGES";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
