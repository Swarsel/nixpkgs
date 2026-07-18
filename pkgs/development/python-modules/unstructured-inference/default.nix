{
  lib,
  fetchFromGitHub,
  # runtime dependencies
  accelerate,
  buildPythonPackage,
  click,
  coverage,
  httpx,
  huggingface-hub,
  layoutparser,
  mypy,
  onnx,
  onnxruntime,
  opencv-python,
  pdf2image,
  pytest-cov-stub,
  # check inputs
  pytestCheckHook,
  python-multipart,
  rapidfuzz,
  setuptools,
  transformers,
}:

buildPythonPackage (finalAttrs: {
  pname = "unstructured-inference";
  version = "1.1.7";

  src = fetchFromGitHub {
    owner = "Unstructured-IO";
    repo = "unstructured-inference";
    tag = finalAttrs.version;
    hash = "sha256-RY+acfyAGP2r8axfifQkTSkbwkrZ0u6KvFwds24IkMc=";
  };

  # This dependency needs to be updated properly
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
    coverage
    click
    httpx
    mypy
    pytest-cov-stub
    pdf2image
    huggingface-hub
  ];

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  build-system = [ setuptools ];

  dependencies = [
    accelerate
    huggingface-hub
    layoutparser
    onnx
    onnxruntime
    opencv-python
    python-multipart
    rapidfuzz
    transformers
    # detectron2 # fails to build
    # paddleocr # 3.12 not yet supported
    # yolox
  ]
  ++ layoutparser.optional-dependencies.layoutmodels
  ++ layoutparser.optional-dependencies.tesseract;

  disabledTestPaths = [
    # network access
    "test_unstructured_inference/inference/test_layout.py"
    "test_unstructured_inference/models/test_chippermodel.py"
    "test_unstructured_inference/models/test_detectron2onnx.py"
    # unclear failure
    "test_unstructured_inference/models/test_donut.py"
    "test_unstructured_inference/models/test_model.py"
    "test_unstructured_inference/models/test_tables.py"
  ];

  disabledTests = [
    # not sure why this fails
    "test_get_path_oob_move_deeply_nested"
    "test_get_path_oob_move_nested[False]"
    # requires yolox
    "test_yolox"
  ];

  pyproject = true;
  pythonImportsCheck = [ "unstructured_inference" ];

  pythonRelaxDeps = [
    # Wants >= 4.13.0.90 but the latest release is 4.13.0
    "opencv-python"
  ];

  meta = {
    description = "Hosted model inference code for layout parsing models";
    homepage = "https://github.com/Unstructured-IO/unstructured-inference";
    changelog = "https://github.com/Unstructured-IO/unstructured-inference/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ happysalada ];

    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
    ];
  };
})
