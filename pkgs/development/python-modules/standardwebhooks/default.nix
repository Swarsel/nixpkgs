{
  lib,
  attrs,
  buildPythonPackage,
  deprecated,
  fetchPypi,
  httpx,
  pytestCheckHook,
  python-dateutil,
  setuptools,
  types-deprecated,
  types-python-dateutil,
}:

buildPythonPackage (finalAttrs: {
  pname = "standardwebhooks";
  version = "1.0.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-tVe7LksWraF5pRfsD+bL7FrPl2xWGZIr8pxFf4mkUb0=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    attrs
    deprecated
    httpx
    python-dateutil
    types-deprecated
    types-python-dateutil
  ];

  pyproject = true;
  pythonImportsCheck = [ "standardwebhooks" ];

  meta = {
    description = "Standard Webhooks";
    homepage = "https://pypi.org/project/standardwebhooks/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
