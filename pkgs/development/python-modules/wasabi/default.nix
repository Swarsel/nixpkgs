{
  lib,
  buildPythonPackage,
  fetchPypi,
  # tests
  ipykernel,
  nbconvert,
  pytestCheckHook,
  setuptools,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "wasabi";
  version = "1.1.3";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-S7MAjwA4CdsMPii02vIJBuqHGiu0P5kUGX1UD08uCHg=";
  };

  nativeCheckInputs = [
    ipykernel
    nbconvert
    typing-extensions
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "wasabi" ];

  meta = {
    description = "Lightweight console printing and formatting toolkit";
    homepage = "https://github.com/explosion/wasabi";
    changelog = "https://github.com/explosion/wasabi/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
