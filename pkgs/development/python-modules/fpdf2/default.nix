{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  camelot,
  defusedxml,
  fonttools,
  lxml,
  pikepdf,
  pillow,
  pytest-cov-stub,
  pytestCheckHook,
  qrcode,
  setuptools,
  uharfbuzz,
}:

buildPythonPackage rec {
  pname = "fpdf2";
  version = "2.8.5";

  src = fetchFromGitHub {
    owner = "py-pdf";
    repo = "fpdf2";
    tag = version;
    hash = "sha256-LQZ7OMfL+PFxEc7q/dSw+YJoKr+eYEaZF8XCzd7AdBI=";
  };

  nativeCheckInputs = [
    camelot
    lxml
    pikepdf
    pytest-cov-stub
    pytestCheckHook
    qrcode
    uharfbuzz
  ];

  build-system = [ setuptools ];

  dependencies = [
    defusedxml
    fonttools
    pillow
  ];

  disabledTestPaths = [
    "test/table/test_table_extraction.py" # tabula-py not packaged yet
    "test/signing/test_sign.py" # endesive not packaged yet
  ];

  disabledTests = [
    "test_png_url" # tries to download file
    "test_page_background" # tries to download file
    "test_share_images_cache" # uses timing functions
    "test_bidi_character" # tries to download file
    "test_bidi_conformance" # tries to download file
    "test_insert_jpg_jpxdecode" # JPEG2000 is broken
  ];

  pyproject = true;

  meta = {
    description = "Simple PDF generation for Python";
    homepage = "https://github.com/py-pdf/fpdf2";
    changelog = "https://github.com/py-pdf/fpdf2/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ jfvillablanca ];
  };
}
