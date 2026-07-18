{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  openapi-schema-validator,
  pytestCheckHook,
  # build-system
  setuptools,
  # dependencies
  voluptuous,
}:

buildPythonPackage (finalAttrs: {
  pname = "voluptuous-openapi";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "home-assistant-libs";
    repo = "voluptuous-openapi";
    tag = finalAttrs.version;
    hash = "sha256-eT0Ej0mylMh/GNUZsr/YPziPad5id2bs2rMtX65BsZA=";
  };

  nativeCheckInputs = [
    openapi-schema-validator
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ voluptuous ];
  pyproject = true;
  pythonImportsCheck = [ "voluptuous_openapi" ];

  meta = {
    description = "Convert voluptuous schemas to OpenAPI Schema object";
    homepage = "https://github.com/home-assistant-libs/voluptuous-openapi";
    changelog = "https://github.com/home-assistant-libs/voluptuous-openapi/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hexa ];
  };
})
