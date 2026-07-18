{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  einops,
  # optional-dependencies
  ipywidgets,
  jupyter,
  matplotlib,
  numpy,
  pandas,
  # tests
  plotly,
  # build-system
  pybind11,
  pytestCheckHook,
  pythonAtLeast,
  pytorch-msssim,
  scipy,
  setuptools,
  tomli,
  torch,
  torch-geometric,
  torchvision,
  tqdm,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "compressai";
  version = "1.2.8";

  src = fetchFromGitHub {
    owner = "InterDigitalInc";
    repo = "CompressAI";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Fgobh7Q1rKomcqAT4kJl2RsM1W13ErO8sFB2urCqrCk=";
    fetchSubmodules = true;
  };

  nativeCheckInputs = [
    plotly
    pytestCheckHook
  ];

  # We have to delete the source because otherwise it is used intead the installed package.
  preCheck = ''
    rm -rf compressai
  '';

  build-system = [
    pybind11
    setuptools
  ];

  dependencies = [
    einops
    matplotlib
    numpy
    pandas
    pytorch-msssim
    scipy
    tomli
    torch
    torch-geometric
    torchvision
    tqdm
    typing-extensions
  ];

  disabledTestPaths = lib.optionals stdenv.hostPlatform.isDarwin [
    # Cause pytest to hang on Darwin after the tests are done
    "tests/test_eval_model.py"
    "tests/test_train.py"

    # fails in sandbox as it tries to launch a web browser (which fails due to missing `osascript`)
    "tests/test_plot.py::test_plot[plotly-ms-ssim-rgb]"
  ];

  disabledTests = [
    # Those tests require internet access to download some weights
    "test_image_codec"
    "test_update"
    "test_eval_model_pretrained"
    "test_cheng2020_anchor"
    "test_pretrained"

    # Flaky (AssertionError: assert 0.08889999999999998 < 0.064445)
    "test_compiling"
    "test_find_close"
  ]
  ++ lib.optionals (pythonAtLeast "3.14") [
    # AttributeError: '...' object has no attribute '__annotations__'
    "test_gdn"
    "test_gdn1"
    "test_lower_bound_script"
  ];

  optional-dependencies = {
    tutorials = [
      ipywidgets
      jupyter
    ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "compressai"
    "compressai._CXX"
  ];

  pythonRelaxDeps = [
    "numpy"
  ];

  meta = {
    description = "PyTorch library and evaluation platform for end-to-end compression research";
    homepage = "https://github.com/InterDigitalInc/CompressAI";
    license = lib.licenses.bsd3Clear;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
