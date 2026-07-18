{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  cryptography,
  fonttools,
  lxml,
  matplotlib,
  pandas,
  pillow,
  pytestCheckHook,
  python-barcode,
  qrcode,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "borb";
  version = "3.0.4";

  src = fetchFromGitHub {
    owner = "jorisschellekens";
    repo = "borb";
    tag = "v${version}";
    hash = "sha256-p9tVG2Pvqk5uDXdeB+7F71w3h4/zut+htlm4p+qqfWA=";
  };

  # ModuleNotFoundError: No module named '_decimal'
  postPatch = lib.optionalString stdenv.hostPlatform.isDarwin ''
    grep -Rl 'from _decimal' tests/ | while read -r test_file; do
      substituteInPlace "$test_file" \
        --replace-fail 'from _decimal' 'from decimal'
    done
  '';

  nativeCheckInputs = [
    matplotlib
    pandas
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    cryptography
    fonttools
    lxml
    pillow
    python-barcode
    qrcode
    requests
    setuptools
  ];

  disabledTestPaths = [
    # Tests require network access
    "tests/pdf/"
    "tests/toolkit/"
    "tests/license/"
  ];

  disabledTests = [
    "test_code_files_are_small"
    "test_image_has_pdfobject_methods"
  ];

  pyproject = true;
  pythonImportsCheck = [ "borb.pdf" ];

  meta = {
    description = "Library for reading, creating and manipulating PDF files in Python";
    homepage = "https://borbpdf.com/";
    changelog = "https://github.com/jorisschellekens/borb/releases/tag/${src.tag}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ getchoo ];
  };
}
