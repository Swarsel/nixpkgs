{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  numpy,
  opencv-python,
  pillow,
  pytestCheckHook,
  requests,
  requests-mock,
  scikit-learn,
  typer,
  typing-extensions,
}:
buildPythonPackage rec {
  pname = "pylette";
  version = "5.3.0";

  src = fetchFromGitHub {
    owner = "qTipTip";
    repo = "Pylette";
    tag = version;
    hash = "sha256-EpmMgbCVUJ86BlWq2LgPKLKjPsfwom7RhrlvqWq/rh8=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    requests-mock
    typer
  ];

  build-system = [
    hatchling
  ];

  dependencies = [
    opencv-python
    scikit-learn
    pillow
    requests
    typer
    typing-extensions
    numpy
  ];

  disabledTests = [
    # hangs forever
    "test_color_extraction_deterministic_kmeans"
    # AssertionError: assert 'Usage: ' in ''
    "test_cli_no_input_is_error"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "Pylette"
  ];

  pythonRelaxDeps = [
    "numpy"
    "Pillow"
    "typer"
  ];

  meta = {
    description = "Python library for extracting color palettes from images";
    homepage = "https://qtiptip.github.io/Pylette/";
    changelog = "https://github.com/qTipTip/Pylette/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ DataHearth ];
  };
}
