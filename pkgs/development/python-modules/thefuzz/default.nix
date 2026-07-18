{
  lib,
  buildPythonPackage,
  fetchPypi,
  hypothesis,
  levenshtein,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "thefuzz";
  version = "0.22.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-cTgDmn7PVA2jI3kthZLvmQKx1563jBR9TyBmTeefNoA=";
  };

  # Skip linting
  postPatch = ''
    substituteInPlace test_thefuzz.py \
      --replace-fail "import pycodestyle" ""
  '';

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ levenshtein ];

  disabledTests = [
    # Skip linting
    "test_pep8_conformance"
  ];

  optional-dependencies = {
    speedup = [ ];
  };

  pyproject = true;
  pythonImportsCheck = [ "thefuzz" ];

  meta = {
    description = "Fuzzy string matching for Python";
    homepage = "https://github.com/seatgeek/thefuzz";
    changelog = "https://github.com/seatgeek/thefuzz/blob/${version}/CHANGES.rst";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ sumnerevans ];
  };
}
