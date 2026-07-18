{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  cysignals,
  cython,
  leptonica,
  # dependencies
  pillow,
  # native dependencies
  pkg-config,
  # tests
  pytestCheckHook,
  setuptools,
  tesseract5,
}:

buildPythonPackage (finalAttrs: {
  pname = "tesserocr";
  version = "2.10.0";

  src = fetchFromGitHub {
    owner = "sirfz";
    repo = "tesserocr";
    tag = "v${finalAttrs.version}";
    hash = "sha256-y/3MXkocO4hRMjREPT6yvqH87EZm79zerinp5TUHNP4=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail \
        "Cython>=3.0.0,<3.2.0" \
        "Cython"
  '';

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    leptonica
    tesseract5
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  preCheck = ''
    rm -rf tesserocr
  '';

  build-system = [
    cysignals
    cython
    setuptools
  ];

  dependencies = [
    cysignals # also needed at runtime
    pillow
  ];

  disabledTests = [
    # AssertionError: '.bl' != '.tif'
    "test_init_full"
  ];

  pyproject = true;
  pythonImportsCheck = [ "tesserocr" ];

  meta = {
    description = "Simple, Pillow-friendly, wrapper around the tesseract-ocr API for Optical Character Recognition (OCR)";
    homepage = "https://github.com/sirfz/tesserocr";
    changelog = "https://github.com/sirfz/tesserocr/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mtrsk ];
    platforms = lib.platforms.unix;
  };
})
