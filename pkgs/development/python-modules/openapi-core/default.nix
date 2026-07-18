{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioitertools,
  buildPythonPackage,
  django,
  falcon,
  fastapi,
  flask,
  httpx,
  isodate,
  jsonschema,
  jsonschema-path,
  more-itertools,
  multidict,
  openapi-schema-validator,
  openapi-spec-validator,
  parse,
  poetry-core,
  pytest-aiohttp,
  pytest-cov-stub,
  pytestCheckHook,
  requests,
  responses,
  starlette,
  webob,
  werkzeug,
}:

buildPythonPackage rec {
  pname = "openapi-core";
  version = "0.23.1";

  src = fetchFromGitHub {
    owner = "p1c2u";
    repo = "openapi-core";
    tag = version;
    hash = "sha256-wGaRx+IEqsvs7ygCDgh1H4di662SQhjmpB9LMP/YGKM=";
  };

  nativeCheckInputs = [
    httpx
    pytest-aiohttp
    pytest-cov-stub
    pytestCheckHook
    responses
    webob
  ]
  ++ lib.concatAttrValues optional-dependencies;

  __darwinAllowLocalNetworking = true;
  build-system = [ poetry-core ];

  dependencies = [
    isodate
    more-itertools
    parse
    openapi-schema-validator
    openapi-spec-validator
    werkzeug
    jsonschema-path
    jsonschema
  ];

  disabledTestPaths = [
    # Requires secrets and additional configuration
    "tests/integration/contrib/django/"
  ];

  disabledTests = [
    # https://github.com/p1c2u/jsonschema-path/pull/262 broke comparison of `SchemaPath`s
    "test_returns_default_server"
  ];

  optional-dependencies = {
    aiohttp = [
      aiohttp
      multidict
    ];

    django = [ django ];
    falcon = [ falcon ];
    fastapi = [ fastapi ];
    flask = [ flask ];
    requests = [ requests ];

    starlette = [
      aioitertools
      starlette
    ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "openapi_core"
    "openapi_core.validation.request.validators"
    "openapi_core.validation.response.validators"
  ];

  pythonRelaxDeps = [
    "jsonschema-path"
  ];

  meta = {
    description = "Client-side and server-side support for the OpenAPI Specification v3";
    homepage = "https://github.com/python-openapi/openapi-core";
    changelog = "https://github.com/python-openapi/openapi-core/releases/tag/${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
