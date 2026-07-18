{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "eradicate";
  version = "3.0.1";

  src = fetchFromGitHub {
    owner = "wemake-services";
    repo = "eradicate";
    tag = version;
    hash = "sha256-D9V9PQ3HVmShmPgTInOJaVmujy1fQyQn6qYn/Pa0kMg=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  enabledTestPaths = [ "test_eradicate.py" ];
  pyproject = true;
  pythonImportsCheck = [ "eradicate" ];

  meta = {
    description = "Library to remove commented-out code from Python files";
    homepage = "https://github.com/myint/eradicate";
    changelog = "https://github.com/wemake-services/eradicate/releases/tag/${src.tag}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ mmlb ];
    mainProgram = "eradicate";
  };
}
