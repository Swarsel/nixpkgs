{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  jsonschema,
  jsonschema-specifications,
  # build-system
  poetry-core,
  pydantic,
  pydantic-settings,
  pytest-cov-stub,
  # tests
  pytestCheckHook,
  referencing,
  # optional-dependencies
  regress,
  rfc3339-validator,
}:

buildPythonPackage rec {
  pname = "openapi-schema-validator";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "p1c2u";
    repo = "openapi-schema-validator";
    tag = version;
    hash = "sha256-XOtSnlJJGEa6pOQDHTFRF0zqNxJIB2VlZvFv5kxwUIM=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  build-system = [ poetry-core ];

  dependencies = [
    jsonschema
    jsonschema-specifications
    pydantic
    pydantic-settings
    referencing
    rfc3339-validator
  ];

  optional-dependencies = {
    ecma-regex = [ regress ];
  };

  pyproject = true;
  pythonImportsCheck = [ "openapi_schema_validator" ];

  meta = {
    description = "Validates OpenAPI schema against the OpenAPI Schema Specification v3.0 and v3.1";
    homepage = "https://github.com/python-openapi/openapi-schema-validator";
    changelog = "https://github.com/python-openapi/openapi-schema-validator/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
