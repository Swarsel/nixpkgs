{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  httpx,
  packaging,
  pydantic,
  pytest-asyncio,
  pytest-recording,
  pytestCheckHook,
  pythonAtLeast,
  respx,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "replicate";
  version = "1.1.0b3";

  src = fetchFromGitHub {
    owner = "replicate";
    repo = "replicate-python";
    tag = version;
    hash = "sha256-wafxaMQhusTr4wYnkrpfXr6FE2rbi6BVq42VSTXdEoc=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
    pytest-recording
    respx
  ];

  build-system = [ setuptools ];

  dependencies = [
    httpx
    packaging
    pydantic
    typing-extensions
  ];

  # uses pydantic.v1 compat layer, unsupported on 3.14
  disabled = pythonAtLeast "3.14";
  pyproject = true;
  pythonImportsCheck = [ "replicate" ];

  meta = {
    description = "Python client for Replicate";
    homepage = "https://replicate.com/";
    changelog = "https://github.com/replicate/replicate-python/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jokatzke ];
  };
}
