{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  onnx,
  # optional-dependencies
  onnxruntime,
  optimum,
  # onnxruntime-gpu, unpackaged
  ruff,
  # build-system
  setuptools,
  transformers,
}:

buildPythonPackage rec {
  pname = "optimum-onnx";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "huggingface";
    repo = "optimum-onnx";
    tag = "v${version}";
    hash = "sha256-Thx3QPLgi8w8znvMGSuCyRu/tUynCkQFywtKKv7UhuA=";
  };

  # Almost all tests need internet access
  doCheck = false;

  build-system = [
    setuptools
  ];

  dependencies = [
    onnx
    optimum
    transformers
  ];

  optional-dependencies = {
    onnxruntime = [
      onnxruntime
    ];
    # onnxruntime-gpu = [ onnxruntime-gpu ];
  };

  pyproject = true;
  pythonImportsCheck = [ "optimum.onnxruntime" ];

  pythonRelaxDeps = [
    "transformers"
  ];

  meta = {
    description = "Export your model to ONNX and run inference with ONNX Runtime";
    homepage = "https://github.com/huggingface/optimum-onnx";
    changelog = "https://github.com/huggingface/optimum-onnx/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
