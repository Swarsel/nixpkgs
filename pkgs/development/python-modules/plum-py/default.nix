{
  lib,
  fetchFromGitLab,
  baseline,
  buildPythonPackage,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "plum-py";
  version = "0.8.7";

  src = fetchFromGitLab {
    owner = "dangass";
    repo = "plum";
    tag = version;
    hash = "sha256-q9UNRZYBLBm0mf/r3cktGnGG9LzmTDrSVgXDgGDBMok=";
  };

  postPatch = ''
    # Drop broken version specifier
    sed -i "/python_requires =/d" setup.cfg
  '';

  nativeCheckInputs = [
    baseline
    pytestCheckHook
  ];

  disabledTestPaths = [
    # tests enum.IntFlag behaviour which has been disallowed in python 3.11.6
    # https://gitlab.com/dangass/plum/-/issues/150
    "tests/flag/test_flag_invalid.py"
  ];

  enabledTestPaths = [ "tests" ];
  format = "setuptools";
  pythonImportsCheck = [ "plum" ];

  meta = {
    description = "Classes and utilities for packing/unpacking bytes";
    homepage = "https://plum-py.readthedocs.io/";
    changelog = "https://gitlab.com/dangass/plum/-/blob/${version}/docs/release_notes.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dnr ];
  };
}
