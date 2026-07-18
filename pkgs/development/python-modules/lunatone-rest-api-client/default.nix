{
  lib,
  fetchFromGitLab,
  aiohttp,
  awesomeversion,
  buildPythonPackage,
  hatchling,
  pydantic,
  pytest-aioresponses,
  pytest-asyncio,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "lunatone-rest-api-client";
  version = "0.9.2";

  src = fetchFromGitLab {
    owner = "lunatone-public";
    repo = "lunatone-rest-api-client";
    tag = "v${version}";
    hash = "sha256-hUc2cMZ2OWheqDQjg6A7mEZw0RrljestouPr1WdOl7Q=";
  };

  nativeCheckInputs = [
    pytest-aioresponses
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    aiohttp
    awesomeversion
    pydantic
  ]
  ++ aiohttp.optional-dependencies.speedups;

  pyproject = true;
  pythonImportsCheck = [ "lunatone_rest_api_client" ];

  meta = {
    description = "Client library for accessing the Lunatone REST API";
    homepage = "https://gitlab.com/lunatone-public/lunatone-rest-api-client";
    changelog = "https://gitlab.com/lunatone-public/lunatone-rest-api-client/-/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.dotlambda ];
  };
}
