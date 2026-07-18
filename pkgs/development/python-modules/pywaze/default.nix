{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  httpx,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  respx,
}:

buildPythonPackage (finalAttrs: {
  pname = "pywaze";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "eifinger";
    repo = "pywaze";
    tag = "v${finalAttrs.version}";
    hash = "sha256-yhECJORKVM8R/+CjhSTwgtCPeQ8QwIuG3EZHmtjVkX0=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
    respx
  ];

  build-system = [ hatchling ];
  dependencies = [ httpx ];
  pyproject = true;
  pythonImportsCheck = [ "pywaze" ];

  meta = {
    description = "Module for calculating WAZE routes and travel times";
    homepage = "https://github.com/eifinger/pywaze";
    changelog = "https://github.com/eifinger/pywaze/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
