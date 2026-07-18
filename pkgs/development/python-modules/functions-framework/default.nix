{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  click,
  cloudevents,
  deprecation,
  # tests
  docker,
  flask,
  gunicorn,
  httpx,
  pretend,
  pytest-asyncio,
  pytestCheckHook,
  pythonAtLeast,
  requests,
  # build-system
  setuptools,
  starlette,
  uvicorn,
  uvicorn-worker,
  watchdog,
  werkzeug,
}:

buildPythonPackage (finalAttrs: {
  pname = "functions-framework";
  version = "3.10.2";

  src = fetchFromGitHub {
    owner = "GoogleCloudPlatform";
    repo = "functions-framework-python";
    tag = "v${finalAttrs.version}";
    hash = "sha256-JiDerfEXlamZWzHxZaTJN/QFMXSph5YDtRsZM4hb4hs=";
  };

  nativeCheckInputs = [
    docker
    httpx
    pretend
    pytest-asyncio
    pytestCheckHook
    requests
  ];

  build-system = [ setuptools ];

  dependencies = [
    click
    cloudevents
    deprecation
    flask
    gunicorn
    starlette
    uvicorn
    uvicorn-worker
    watchdog
    werkzeug
  ];

  disabledTestPaths = lib.optionals (pythonAtLeast "3.14") [
    # _pickle.PicklingError: Can't pickle local object <function Flask.__init__.<locals>.<lambda> at 0x7ffff47e54e0>
    "tests/test_timeouts.py"
  ];

  disabledTests = [
    # Test requires a running Docker instance
    "test_cloud_run_http"
  ];

  pyproject = true;
  pythonImportsCheck = [ "functions_framework" ];

  pythonRelaxDeps = [
    "cloudevents"
  ];

  meta = {
    description = "FaaS (Function as a service) framework for writing portable Python functions";
    homepage = "https://github.com/GoogleCloudPlatform/functions-framework-python";
    changelog = "https://github.com/GoogleCloudPlatform/functions-framework-python/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
