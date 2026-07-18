{
  lib,
  buildPythonPackage,
  fetchPypi,
  fuzzywuzzy,
  levenshtein,
  opencv-python,
  pytesseract,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "videocr";
  version = "0.1.6";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-w0hPfUK4un5JAjAP7vwOAuKlsZ+zv6sFV2vD/Rl3kbI=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "python-Levenshtein" "Levenshtein"
    substituteInPlace videocr/constants.py \
      --replace-fail "master" "main"
    substituteInPlace videocr/video.py \
      --replace-fail '--tessdata-dir "{}"' '--tessdata-dir="{}"'
  '';

  # Project has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    levenshtein
    pytesseract
    opencv-python
    fuzzywuzzy
  ];

  pyproject = true;
  pythonImportsCheck = [ "videocr" ];

  meta = {
    description = "Extract hardcoded subtitles from videos using machine learning";
    homepage = "https://github.com/apm1467/videocr";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ozkutuk ];
  };
})
