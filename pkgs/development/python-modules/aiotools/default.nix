{
  lib,
  fetchFromGitHub,
  async-lru,
  buildPythonPackage,
  pytest-asyncio,
  pytestCheckHook,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "aiotools";
  version = "2.2.3";

  src = fetchFromGitHub {
    owner = "achimnol";
    repo = "aiotools";
    tag = finalAttrs.version;
    hash = "sha256-uIG3JPqep4NGtZa7Qo8SOK9Ca1GNKyuBasFtwR9oG8U=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
  ];

  build-system = [
    setuptools-scm
  ];

  dependencies = [
    async-lru
  ];

  pyproject = true;
  pythonImportsCheck = [ "aiotools" ];

  meta = {
    description = "Idiomatic asyncio utilities";
    homepage = "https://github.com/achimnol/aiotools";
    changelog = "https://github.com/achimnol/aiotools/blob/${finalAttrs.src.tag}/CHANGES.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ robertjakub ];
  };
})
