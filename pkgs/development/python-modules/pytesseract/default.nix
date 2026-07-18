{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  packaging,
  pillow,
  pytestCheckHook,
  replaceVars,
  setuptools,
  tesseract,
}:

buildPythonPackage rec {
  pname = "pytesseract";
  version = "0.3.13";

  src = fetchFromGitHub {
    owner = "madmaze";
    repo = "pytesseract";
    tag = "v${version}";
    hash = "sha256-gQMeck6ojlIwyiOCBBhzHHrjQfBMelVksVGd+fyxWZk=";
  };

  patches = [
    (replaceVars ./tesseract-binary.patch {
      drv = tesseract;
    })
  ];

  nativeBuildInputs = [ setuptools ];
  buildInputs = [ tesseract ];

  propagatedBuildInputs = [
    packaging
    pillow
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  disabledTests = [
    # https://github.com/madmaze/pytesseract/pull/559
    "incorrect_tessdata_dir"
    "invalid_tessdata_dir"
  ];

  pyproject = true;

  meta = {
    description = "Python wrapper for Google Tesseract";
    homepage = "https://pypi.org/project/pytesseract/";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "pytesseract";
  };
}
