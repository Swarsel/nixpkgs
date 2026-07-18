{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "ahocorapy";
  version = "1.6.2";

  src = fetchFromGitHub {
    owner = "abusix";
    repo = "ahocorapy";
    tag = version;
    hash = "sha256-ynVkDnrZ12dpNPoKfUdw0/X06aORFkmXFMVH9u0Payo=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  enabledTestPaths = [
    "tests/ahocorapy_test.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "ahocorapy" ];
  pythonRemoveDeps = [ "future" ];

  meta = {
    description = "Pure python Aho-Corasick library";
    homepage = "https://github.com/abusix/ahocorapy";
    changelog = "https://github.com/abusix/ahocorapy/blob/${src.tag}/CHANGELOG";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
