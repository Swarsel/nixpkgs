{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  chardet,
  click,
  flex,
  openapi-spec-validator,
  packaging,
  pyicu,
  pytest-cov-stub,
  pytestCheckHook,
  requests,
  ruamel-yaml,
  setuptools-scm,
  six,
  swagger-spec-validator,
}:

buildPythonPackage rec {
  pname = "prance";
  version = "25.04.08.0";

  src = fetchFromGitHub {
    owner = "RonnyPfannschmidt";
    repo = "prance";
    tag = "v${version}";
    hash = "sha256-71M9ufxb0aaSgokThlsTS4ElOJLZntF2TYIErPccQbU=";
    fetchSubmodules = true;
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ setuptools-scm ];

  dependencies = [
    chardet
    packaging
    requests
    ruamel-yaml
    six
  ];

  # Disable tests that require network
  disabledTestPaths = [ "tests/test_convert.py" ];

  disabledTests = [
    "test_convert_defaults"
    "test_convert_output"
    "test_fetch_url_http"
    "test_openapi_spec_validator_validate_failure"
  ];

  optional-dependencies = {
    cli = [ click ];
    flex = [ flex ];
    icu = [ pyicu ];
    osv = [ openapi-spec-validator ];
    ssv = [ swagger-spec-validator ];
  };

  pyproject = true;
  pythonImportsCheck = [ "prance" ];

  meta = {
    description = "Resolving Swagger/OpenAPI 2.0 and 3.0.0 Parser";
    homepage = "https://github.com/RonnyPfannschmidt/prance";
    changelog = "https://github.com/RonnyPfannschmidt/prance/blob/${src.rev}/CHANGES.rst";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "prance";
  };
}
