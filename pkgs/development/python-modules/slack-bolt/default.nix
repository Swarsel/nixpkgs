{
  lib,
  fetchFromGitHub,
  # optional-dependencies
  # - async
  aiohttp,
  # - adapter
  bottle,
  buildPythonPackage,
  chalice,
  cherrypy,
  django,
  # tests
  docker,
  falcon,
  fastapi,
  flask,
  gunicorn,
  moto,
  pyramid,
  pytest-asyncio_0,
  pytestCheckHook,
  sanic,
  sanic-testing,
  # build-system
  setuptools,
  # dependencies
  slack-sdk,
  starlette,
  tornado,
  uvicorn,
  websocket-client,
  websockets,
  werkzeug,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "slack-bolt";
  version = "1.29.0";

  src = fetchFromGitHub {
    owner = "slackapi";
    repo = "bolt-python";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3U15V++q/x73LuEgw9uWaIGWulJmPkmkpUxxK1EXuzU=";
  };

  nativeCheckInputs = [
    docker
    pytest-asyncio_0
    pytestCheckHook
    writableTmpDirAsHomeHook
  ]
  ++ lib.flatten (builtins.attrValues finalAttrs.passthru.optional-dependencies);

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];
  dependencies = [ slack-sdk ];

  disabledTestPaths = [
    # boddle is not packaged as of 2023-07-15
    "tests/adapter_tests/bottle/"
  ];

  disabledTests = [
    # Require network access
    "test_failure"
    # TypeError
    "test_oauth"
    # AssertionError
    "test_buffer_size_overrides"
    "test_buffer_size_overrides"
    "test_default_params"
    "test_default_params"
    "test_parameter_overrides"
    "test_parameter_overrides"
  ];

  optional-dependencies = {
    adapter = [
      bottle
      chalice
      cherrypy
      django
      falcon
      fastapi
      flask
      gunicorn
      moto
      pyramid
      sanic
      sanic-testing
      starlette
      tornado
      uvicorn
      websocket-client
      werkzeug
    ];

    async = [
      aiohttp
      websockets
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "slack_bolt" ];

  meta = {
    description = "Framework to build Slack apps using Python";
    homepage = "https://github.com/slackapi/bolt-python";
    changelog = "https://github.com/slackapi/bolt-python/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ samuela ];
  };
})
