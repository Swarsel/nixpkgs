{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pycdlib";
  version = "1.16.0";

  src = fetchFromGitHub {
    owner = "clalancette";
    repo = "pycdlib";
    tag = "v${version}";
    hash = "sha256-uJ9rMriRCLXpKekG8vGsIw+s0e6wlfX0soAYs6HGe0Y=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  disabledTestPaths = [
    # These tests require a Fedora-patched genisoimage
    "tests/integration/test_hybrid.py"
    "tests/integration/test_parse.py"
    "tests/tools/test_pycdlib_genisoimage.py"
  ];

  disabledTests = [
    # Timezone-dependent tests fail in the sandbox
    "test_volumedescdate_new_nonzero"
    "test_gmtoffset_from_tm"
    "test_gmtoffset_from_tm_day_rollover"
    "test_gmtoffset_from_tm_2023_rollover"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pycdlib" ];

  meta = {
    description = "Pure python library to read and write ISO9660 files";
    homepage = "https://github.com/clalancette/pycdlib";
    license = lib.licenses.lgpl2Only;
    maintainers = with lib.maintainers; [ Enzime ];
    platforms = lib.platforms.all;
  };
}
