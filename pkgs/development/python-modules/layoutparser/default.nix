{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  effdet,
  google-cloud-vision,
  iopath,
  # build inputs
  numpy,
  opencv-python,
  pandas,
  pdf2image,
  pdfplumber,
  pillow,
  pytesseract,
  # check inputs
  pytestCheckHook,
  pyyaml,
  scipy,
  torch,
  torchvision,
}:
let
  pname = "layoutparser";
  version = "0.3.4";
  optional-dependencies = {
    effdet = [
      torch
      torchvision
      effdet
    ];

    gcv = [ google-cloud-vision ];

    layoutmodels = [
      torch
      torchvision
      effdet
    ];

    ocr = [
      google-cloud-vision
      pytesseract
    ];

    tesseract = [ pytesseract ];
    # paddledetection = [ paddlepaddle ]
  };
in
buildPythonPackage {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "Layout-Parser";
    repo = "layout-parser";
    tag = "v${version}";
    hash = "sha256-qBzcIUmgnGy/Xn/B+7UrLrRhCvCkapL+ymqGS2sMVgA=";
  };

  patches = [
    # https://github.com/Layout-Parser/layout-parser/pull/230
    ./pandas-v3.patch
  ];

  propagatedBuildInputs = [
    numpy
    opencv-python
    scipy
    pandas
    pillow
    pyyaml
    iopath
    pdfplumber
    pdf2image
  ];

  nativeCheckInputs = [ pytestCheckHook ] ++ optional-dependencies.ocr;

  disabledTestPaths = [
    "tests_deps/test_only_detectron2.py" # requires detectron2 not yet packaged
    "tests_deps/test_only_effdet.py" # requires effdet (disable for now until effdet builds on darwin)
    "tests_deps/test_only_paddledetection.py" # requires paddlepaddle not yet packaged
  ];

  disabledTests = [
    "test_PaddleDetectionModel" # requires paddlepaddle not yet packaged
    # requires detectron2 not yet packaged
    "test_Detectron2Model"
    "test_AutoModel"
    # requires effdet (disable for now until effdet builds on darwin)
    "test_EffDetModel"
    # problems with google-cloud-vision
    # AttributeError: module 'google.cloud.vision' has no attribute 'types'
    "test_gcv_agent"
    "test_viz"
    #  - Failed: DID NOT RAISE <class 'ImportError'>
    "test_when_backends_are_not_loaded"
  ];

  format = "setuptools";
  optional-dependencies = optional-dependencies;
  pythonImportsCheck = [ "layoutparser" ];

  meta = {
    description = "Unified toolkit for Deep Learning Based Document Image Analysis";
    homepage = "https://github.com/Layout-Parser/layout-parser";
    changelog = "https://github.com/Layout-Parser/layout-parser/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ happysalada ];
  };
}
