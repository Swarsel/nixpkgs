{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  importlib-resources,
  jsonschema,
  mock,
  pytestCheckHook,
  pyyaml,
  setuptools,
  six,
}:

buildPythonPackage (finalAttrs: {
  pname = "swagger-spec-validator";
  version = "3.0.4";

  src = fetchFromGitHub {
    owner = "Yelp";
    repo = "swagger_spec_validator";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8T0973g8JZKLCTpYqyScr/JAiFdBexEReUJoMQh4vO4=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    mock
  ];

  build-system = [ setuptools ];

  dependencies = [
    pyyaml
    importlib-resources
    jsonschema
    six
  ];

  pyproject = true;
  pythonImportsCheck = [ "swagger_spec_validator" ];

  meta = {
    description = "Validation of Swagger specifications";
    homepage = "https://github.com/Yelp/swagger_spec_validator";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ vanschelven ];
  };
})
