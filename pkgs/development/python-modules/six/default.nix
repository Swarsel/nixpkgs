{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  isPyPy,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "six";
  version = "1.17.0";

  src = fetchFromGitHub {
    owner = "benjaminp";
    repo = "six";
    tag = version;
    hash = "sha256-tz99C+dz5xJhunoC45bl0NdSdV9NXWya9ti48Z/KaHY=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  disabledTestPaths = lib.optionals isPyPy [
    # uses ctypes to find native library
    "test_six.py::test_move_items"
  ];

  pyproject = true;
  pythonImportsCheck = [ "six" ];

  meta = {
    description = "Python 2 and 3 compatibility library";
    homepage = "https://github.com/benjaminp/six";
    changelog = "https://github.com/benjaminp/six/blob/${version}/CHANGES";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
