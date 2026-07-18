{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  onnx,
  onnxruntime,
  packaging,
  protobuf,
  setuptools,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "onnxconverter-common";
  version = "0.16.0";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "onnxconverter-common";
    tag = "v${version}";
    hash = "sha256-M62mbIqFwnPdRlf6J8DrNRhLH0uHns51K/pWnWLxI5Q=";
  };

  # Failing tests
  # https://github.com/microsoft/onnxconverter-common/issues/242
  doCheck = false;

  nativeCheckInputs = [
    onnxruntime
    unittestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    numpy
    packaging
    protobuf
    onnx
  ];

  pyproject = true;
  pythonImportsCheck = [ "onnxconverter_common" ];
  pythonRelaxDeps = [ "protobuf" ];

  unittestFlagsArray = [
    "-s"
    "tests"
  ];

  meta = {
    description = "ONNX Converter and Optimization Tools";
    homepage = "https://github.com/microsoft/onnxconverter-common";
    changelog = "https://github.com/microsoft/onnxconverter-common/releases/tag/${src.tag}";
    license = with lib.licenses; [ mit ];
  };
}
