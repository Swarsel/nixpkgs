{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "json-repair";
  version = "0.55.2";

  src = fetchFromGitHub {
    owner = "mangiucugna";
    repo = "json_repair";
    tag = "v${version}";
    hash = "sha256-CzoGu6JNOaqdLZK4DyDUv+TMIA+k9AlZZy1fKnpMbkE=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  disabledTestPaths = [
    # Disable benchmark tests
    "tests/test_performance.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "json_repair" ];

  meta = {
    description = "Module to repair invalid JSON, commonly used to parse the output of LLMs";
    homepage = "https://github.com/mangiucugna/json_repair/";
    changelog = "https://github.com/mangiucugna/json_repair/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ greg ];
    mainProgram = "json_repair";
  };
}
