{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  httpx,
  pytest-asyncio,
  pytestCheckHook,
  starlette,
}:

buildPythonPackage (finalAttrs: {
  pname = "starlette-context";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "tomwojcik";
    repo = "starlette-context";
    tag = "v${finalAttrs.version}";
    hash = "sha256-cxhTrLLIjlqaR07VVgHmvYctk7+7fDjbGb39PbJbGgk=";
  };

  nativeCheckInputs = [
    httpx
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ hatchling ];
  dependencies = [ starlette ];
  pyproject = true;
  pythonImportsCheck = [ "starlette_context" ];

  meta = {
    description = "Middleware for Starlette that allows you to store and access the context data of a request";
    homepage = "https://github.com/tomwojcik/starlette-context";
    changelog = "https://github.com/tomwojcik/starlette-context/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
