{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cu2qu,
  defcon,
  fontfeatures,
  fonttools,
  glyphslib,
  openstep-plist,
  orjson,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  ufolib2,
  ufomerge,
  vfblib,
}:

buildPythonPackage rec {
  pname = "babelfont";
  version = "3.1.3";

  # PyPI source tarballs omit tests, fetch from Github instead
  src = fetchFromGitHub {
    owner = "simoncozens";
    repo = "babelfont";
    tag = "v${version}";
    hash = "sha256-wCJNJZqjMm0M00F9/kd/g97+DRdRPTn03Nk3rnh7me4=";
  };

  nativeCheckInputs = [
    defcon
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    cu2qu
    fontfeatures
    fonttools
    glyphslib
    openstep-plist
    orjson
    ufolib2
    ufomerge
    vfblib
  ];

  disabledTestPaths = [ "tests/test_glyphs3_roundtrip.py" ];

  # Want non existing test data
  disabledTests = [
    "test_rename"
    "test_rename_nested"
    "test_rename_contextual"
  ];

  pyproject = true;

  meta = {
    description = "Python library to load, examine, and save fonts in a variety of formats";
    homepage = "https://github.com/simoncozens/babelfont";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ danc86 ];
    mainProgram = "babelfont";
  };
}
