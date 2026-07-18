{
  lib,
  babelfont,
  buildPythonPackage,
  fetchPypi,
  fonttools,
  lxml,
  pytestCheckHook,
  setuptools-scm,
  youseedee,
}:

buildPythonPackage rec {
  pname = "fontfeatures";
  version = "1.9.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-3PpUgaTXyFcthJrFaQqeUOvDYYFosJeXuRFnFrwp0R8=";
    pname = "fontfeatures";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools-scm ];

  dependencies = [
    fonttools
    lxml
  ];

  disabledTestPaths = [
    # These tests require babelfont but we have to leave it out and skip them
    # to break the cyclic dependency with babelfont.
    "tests/test_shaping_generic.py"
    "tests/test_shaping_harfbuzz.py"
  ];

  optional-dependencies.shaper = [
    babelfont
    youseedee
  ];

  pyproject = true;

  meta = {
    description = "Python library for compiling OpenType font features";
    homepage = "https://github.com/simoncozens/fontFeatures";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ danc86 ];
  };
}
