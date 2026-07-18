{
  lib,
  buildPythonPackage,
  # dependencies
  coloredlogs,
  fetchPypi,
  numpy,
  onnx,
  packaging,
  psutil,
  py-cpuinfo,
  py3nvml,
  sympy,
}:

buildPythonPackage rec {
  pname = "onnxruntime-tools";
  version = "1.7.0";

  # the build distribution doesn't work at all, it seems to expect the same structure
  # as the github source repo.
  # The github source wasn't immediately obvious how to build for this subpackage.
  src = fetchPypi {
    inherit version;
    hash = "sha256-Hf+Ii1xIKsW8Yn8S4QhEX+/LPWAMQ/Y2M5dTFv5hetg=";
    dist = "py3";
    format = "wheel";
    pname = "onnxruntime_tools";
    python = "py3";
  };

  # no tests
  doCheck = false;

  dependencies = [
    coloredlogs
    numpy
    onnx
    packaging
    psutil
    py-cpuinfo
    py3nvml
    sympy
  ];

  format = "wheel";
  pythonImportsCheck = [ "onnxruntime_tools" ];

  meta = {
    description = "Transformers Model Optimization Tool of ONNXRuntime";
    homepage = "https://pypi.org/project/onnxruntime-tools/";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ happysalada ];
  };
}
