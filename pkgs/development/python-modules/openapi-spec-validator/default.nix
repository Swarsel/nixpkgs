{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # propagates
  jsonschema,
  jsonschema-path,
  lazy-object-proxy,
  openapi-schema-validator,
  # build-system
  poetry-core,
  pytest-cov-stub,
  # tests
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "openapi-spec-validator";
  version = "0.8.4";

  # no tests via pypi sdist
  src = fetchFromGitHub {
    owner = "python-openapi";
    repo = "openapi-spec-validator";
    tag = version;
    hash = "sha256-KY9mDnF/R2UO8WZ0WyBzpZQsVBxzxnTK6zyqvUb+hVw=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  build-system = [ poetry-core ];

  dependencies = [
    jsonschema
    jsonschema-path
    lazy-object-proxy
    openapi-schema-validator
  ];

  disabledTests = [
    # network access
    "test_default_valid"
    "test_urllib_valid"
    "test_valid"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "openapi_spec_validator"
    "openapi_spec_validator.readers"
  ];

  pythonRelaxDeps = [
    "jsonschema"
  ];

  meta = {
    description = "Validates OpenAPI Specs against the OpenAPI 2.0 (aka Swagger) and OpenAPI 3.0.0 specification";
    homepage = "https://github.com/p1c2u/openapi-spec-validator";
    changelog = "https://github.com/p1c2u/openapi-spec-validator/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    mainProgram = "openapi-spec-validator";
  };
}
