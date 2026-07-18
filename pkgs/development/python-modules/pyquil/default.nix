{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  deprecated,
  ipython,
  matplotlib-inline,
  nest-asyncio,
  networkx,
  numpy,
  packaging,
  poetry-core,
  pytest-asyncio,
  pytest-mock,
  pytestCheckHook,
  pythonAtLeast,
  qcs-sdk-python,
  respx,
  rpcq,
  scipy,
  syrupy,
  types-deprecated,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "pyquil";
  version = "4.17.0";

  src = fetchFromGitHub {
    owner = "rigetti";
    repo = "pyquil";
    tag = "v${version}";
    hash = "sha256-El0eMBUOYpB0v+duPEnIQTbJLKTguq4yTsItbriRbg4=";
  };

  # tests hang
  doCheck = false;

  nativeCheckInputs = [
    nest-asyncio
    pytest-asyncio
    pytest-mock
    pytestCheckHook
    respx
    syrupy
    ipython
  ];

  build-system = [ poetry-core ];

  dependencies = [
    deprecated
    matplotlib-inline
    networkx
    numpy
    packaging
    qcs-sdk-python
    rpcq
    scipy
    types-deprecated
    typing-extensions
  ];

  # qcs-sdk-python (PyO3) caps at 3.12; upstream also pins python <3.13
  disabled = pythonAtLeast "3.13";
  pyproject = true;
  pythonImportsCheck = [ "pyquil" ];

  pythonRelaxDeps = [
    "lark"
    "networkx"
    "numpy"
    "packaging"
    "qcs-sdk-python"
    "rpcq"
  ];

  meta = {
    description = "Python library for creating Quantum Instruction Language (Quil) programs";
    homepage = "https://github.com/rigetti/pyquil";
    changelog = "https://github.com/rigetti/pyquil/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
