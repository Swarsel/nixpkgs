{
  lib,
  fetchFromGitHub,
  annotated-types,
  buildPythonPackage,
  dataclass-wizard,
  hatchling,
  pytest-asyncio,
  pytestCheckHook,
  requests,
  responses,
}:

buildPythonPackage rec {
  pname = "todoist-api-python";
  version = "3.2.1";

  src = fetchFromGitHub {
    owner = "Doist";
    repo = "todoist-api-python";
    tag = "v${version}";
    hash = "sha256-udYFWTrWW2G6JBKQUkiqKpyBz1D4dwq7Pix6bzuWnDY=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
    responses
  ];

  build-system = [ hatchling ];

  dependencies = [
    annotated-types
    dataclass-wizard
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "todoist_api_python" ];

  meta = {
    description = "Library for the Todoist REST API";
    homepage = "https://github.com/Doist/todoist-api-python";
    changelog = "https://github.com/Doist/todoist-api-python/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
