{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pyheck,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "dotwiz";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "rnag";
    repo = "dotwiz";
    tag = "v${version}";
    hash = "sha256-ABmkwpJ40JceNJieW5bhg0gqWNrR6Wxj84nLCjKU11A=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ pyheck ];
  disabledTestPaths = [ "benchmarks" ];
  pyproject = true;
  pythonImportsCheck = [ "dotwiz" ];

  meta = {
    description = "Dict subclass that supports dot access notation";
    homepage = "https://github.com/rnag/dotwiz";
    changelog = "https://github.com/rnag/dotwiz/blob/${src.tag}/HISTORY.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
