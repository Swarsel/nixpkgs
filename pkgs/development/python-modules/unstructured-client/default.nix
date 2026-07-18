{
  lib,
  fetchFromGitHub,
  aiofiles,
  buildPythonPackage,
  deepdiff,
  httpcore,
  httpx,
  pydantic,
  pypdf,
  pypdfium2,
  pytest-asyncio,
  pytestCheckHook,
  python,
  requests-toolbelt,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "unstructured-client";
  version = "0.45.0";

  src = fetchFromGitHub {
    owner = "Unstructured-IO";
    repo = "unstructured-python-client";
    tag = "v${finalAttrs.version}";
    hash = "sha256-K4+k1wKFvT2JYElt2SdBFKJGpFdC15Bu8Aa+M/c7JSQ=";
  };

  preBuild = ''
    ${python.interpreter} scripts/prepare_readme.py
  '';

  nativeCheckInputs = [
    deepdiff
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiofiles
    httpcore
    httpx
    pydantic
    pypdf
    pypdfium2
    requests-toolbelt
  ];

  # see test-unit in Makefile
  enabledTestPaths = [
    "_test_unstructured_client"
  ];

  enabledTests = [
    "unit"
  ];

  pyproject = true;
  pythonImportsCheck = [ "unstructured_client" ];

  meta = {
    description = "Python Client SDK for Unstructured API";
    homepage = "https://github.com/Unstructured-IO/unstructured-python-client";
    changelog = "https://github.com/Unstructured-IO/unstructured-python-client/blob/${finalAttrs.src.tag}/RELEASES.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
})
