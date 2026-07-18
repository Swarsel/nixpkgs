{
  lib,
  fetchFromGitHub,
  aiofiles,
  buildPythonPackage,
  colorama,
  git,
  jsonschema,
  pdm-backend,
  pytest-gitconfig,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "griffe";
  version = "1.15.0";

  src = fetchFromGitHub {
    owner = "mkdocstrings";
    repo = "griffe";
    tag = version;
    hash = "sha256-AMMTAqsJfj2MltTgAxfvjUTVzi+ZFmx+J9pzhMp28Z4=";
  };

  nativeCheckInputs = [
    git
    jsonschema
    pytest-gitconfig
    pytestCheckHook
  ];

  build-system = [ pdm-backend ];
  dependencies = [ colorama ];

  disabledTestPaths = [
    # Circular dependencies
    "tests/test_api.py"
  ];

  optional-dependencies = {
    async = [ aiofiles ];
  };

  pyproject = true;
  pythonImportsCheck = [ "griffe" ];

  meta = {
    description = "Signatures for entire Python programs";
    homepage = "https://github.com/mkdocstrings/griffe";
    changelog = "https://github.com/mkdocstrings/griffe/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "griffe";
  };
}
