{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  deprecation,
  flask,
  pydantic,
  pytestCheckHook,
  pythonAtLeast,
  requests,
  sanic,
  sanic-testing,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "cloudevents";
  version = "1.12.0";

  src = fetchFromGitHub {
    owner = "cloudevents";
    repo = "sdk-python";
    tag = finalAttrs.version;
    hash = "sha256-0WdCBwYz3XJWjUP0gf+IWdF4ZgPHFvUZFoQp9taqNz8=";
  };

  nativeCheckInputs = [
    flask
    pydantic
    pytestCheckHook
    requests
    sanic
    sanic-testing
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];
  dependencies = [ deprecation ];

  disabledTestPaths = [
    "samples/http-image-cloudevents/image_sample_test.py"
  ]
  # pydantic v1 doesn't work on python 3.14
  ++ lib.optionals (pythonAtLeast "3.14") [
    "cloudevents/tests/test_pydantic_cloudevent.py"
    "cloudevents/tests/test_pydantic_conversions.py"
    "cloudevents/tests/test_pydantic_events.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "cloudevents" ];

  meta = {
    description = "Python SDK for CloudEvents";
    homepage = "https://github.com/cloudevents/sdk-python";
    changelog = "https://github.com/cloudevents/sdk-python/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
