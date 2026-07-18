{
  lib,
  buildPythonPackage,
  fetchPypi,
  levenshtein,
  pycodestyle,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "fuzzywuzzy";
  version = "0.18.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    sha256 = "1s00zn75y2dkxgnbw8kl8dw4p1mc77cv78fwfa4yb0274s96w0a5";
    pname = "fuzzywuzzy";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pycodestyle
  ];

  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ levenshtein ];
  pyproject = true;

  pythonImportsCheck = [
    "fuzzywuzzy"
  ];

  meta = {
    description = "Fuzzy string matching for Python";
    homepage = "https://github.com/seatgeek/fuzzywuzzy";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ erikarvstedt ];
  };
})
