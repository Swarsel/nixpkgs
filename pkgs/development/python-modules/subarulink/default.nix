{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  cryptography,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  pythonOlder,
  setuptools,
  stdiomask,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "subarulink";
  version = "0.7.19";

  src = fetchFromGitHub {
    owner = "G-Two";
    repo = "subarulink";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+huEDrcMjCMUKnzL0wfqnpVjIm8zebV3qAq4OWLZ+GU=";
  };

  nativeCheckInputs = [
    cryptography
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    stdiomask
  ];

  disabled = pythonOlder "3.12";
  pyproject = true;
  pythonImportsCheck = [ "subarulink" ];

  meta = {
    description = "Python module for interacting with STARLINK-enabled vehicle";
    homepage = "https://github.com/G-Two/subarulink";
    changelog = "https://github.com/G-Two/subarulink/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "subarulink";
  };
})
