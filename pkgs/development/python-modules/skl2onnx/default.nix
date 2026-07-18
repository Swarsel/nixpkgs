{
  lib,
  buildPythonPackage,
  fetchPypi,
  numpy,
  onnx,
  onnxconverter-common,
  onnxruntime,
  pandas,
  protobuf,
  scikit-learn,
  scipy,
  setuptools,
  unittestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "skl2onnx";
  version = "1.20.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-x06oJ9kroYb+ZZaV6PyYnNl7/DIO3OPTK5k2pYeNoQo=";
  };

  propagatedBuildInputs = [
    numpy
    scipy
    protobuf
    onnx
    scikit-learn
    onnxconverter-common
  ];

  # Core dump
  doCheck = false;

  nativeCheckInputs = [
    onnxruntime
    pandas
    unittestCheckHook
  ];

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "skl2onnx" ];
  pythonRelaxDeps = [ "scikit-learn" ];

  unittestFlagsArray = [
    "-s"
    "tests"
  ];

  meta = {
    description = "Convert scikit-learn models to ONNX";
    changelog = "https://github.com/onnx/sklearn-onnx/releases/tag/${finalAttrs.version}";
    license = with lib.licenses; [ asl20 ];
  };
})
