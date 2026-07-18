{
  lib,
  fetchFromGitHub,
  authlib,
  buildPythonPackage,
  fastapi,
  httpx,
  httpx-sse,
  mashumaro,
  pytest-asyncio,
  pytest-cov-stub,
  pytest-httpx,
  pytestCheckHook,
  setuptools,
  sybil,
  typer,
  uvicorn,
}:

buildPythonPackage (finalAttrs: {
  pname = "aiohomeconnect";
  version = "0.38.0";

  src = fetchFromGitHub {
    owner = "MartinHjelmare";
    repo = "aiohomeconnect";
    tag = "v${finalAttrs.version}";
    hash = "sha256-KJlkJXxbTSA1j/lvCAsIEheF5h2HQpJXVmiM3dyINPw=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-cov-stub
    pytest-httpx
    pytestCheckHook
    sybil
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  build-system = [ setuptools ];

  dependencies = [
    httpx
    httpx-sse
    mashumaro
  ];

  optional-dependencies = {
    cli = [
      authlib
      fastapi
      typer
      uvicorn
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "aiohomeconnect" ];

  meta = {
    description = "Client for the Home Connect API";
    homepage = "https://github.com/MartinHjelmare/aiohomeconnect";
    changelog = "https://github.com/MartinHjelmare/aiohomeconnect/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
