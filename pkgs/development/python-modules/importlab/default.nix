{
  lib,
  buildPythonPackage,
  fetchPypi,
  networkx,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "importlab";
  version = "0.8.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-s4k4U7H26wJ9pQnDtA5nh+ld1mtLZvGzYTqtd1VuFGU=";
  };

  propagatedBuildInputs = [ networkx ];
  nativeCheckInputs = [ pytestCheckHook ];
  disabledTestPaths = [ "tests/test_parsepy.py" ];
  # Test fails on darwin filesystem
  disabledTests = [ "testIsDir" ];
  format = "setuptools";
  pythonImportsCheck = [ "importlab" ];

  meta = {
    description = "Library that automatically infers dependencies for Python files";
    homepage = "https://github.com/google/importlab";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sei40kr ];
    mainProgram = "importlab";
  };
}
