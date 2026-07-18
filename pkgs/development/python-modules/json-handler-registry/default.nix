{
  lib,
  buildPythonPackage,
  dataclasses-json,
  fetchFromBitbucket,
  pytest-mock,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "json-handler-registry";
  version = "1.5.1";

  src = fetchFromBitbucket {
    owner = "massultidev";
    repo = "json-handler-registry";
    tag = finalAttrs.version;
    hash = "sha256-oB2zsA6H1D27m87+mBKCDaN/kuxtc74RY29zSXovBKU=";
  };

  nativeCheckInputs = [
    dataclasses-json
    pytest-mock
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "json_handler_registry" ];

  meta = {
    description = "Registry for JSON handlers";
    homepage = "https://bitbucket.org/massultidev/json-handler-registry";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
