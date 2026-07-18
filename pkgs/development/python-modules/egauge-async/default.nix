{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  httpx,
  pytest-asyncio,
  pytest-mock,
  pytestCheckHook,
  uv-dynamic-versioning,
}:

buildPythonPackage (finalAttrs: {
  pname = "egauge-async";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "neggert";
    repo = "egauge-async";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MbOjyHxCZpJDZIRyWShk2+X1Di8zX4JjyEpLUnHfdzE=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-mock
    pytestCheckHook
  ];

  build-system = [
    hatchling
    uv-dynamic-versioning
  ];

  dependencies = [
    httpx
  ];

  disabledTestMarks = [
    "integration"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "egauge_async"
  ];

  meta = {
    description = "Async client for eGauge energy monitor";
    homepage = "https://github.com/neggert/egauge-async";
    changelog = "https://github.com/neggert/egauge-async/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ jamiemagee ];
  };
})
