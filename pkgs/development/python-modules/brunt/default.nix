{
  lib,
  aiohttp,
  buildPythonPackage,
  fetchPypi,
  pytest-cov-stub,
  pytestCheckHook,
  requests,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "brunt";
  version = "1.2.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-5wRifce5wKUMZ66Q8dMgsU+Z8rL8m/HvBGGxQdzxvOk=";
  };

  # tests require Brunt hardware
  doCheck = false;

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
  ];

  __structuredAttrs = true;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    aiohttp
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "brunt" ];

  meta = {
    description = "Unofficial Python SDK for Brunt";
    homepage = "https://github.com/eavanvalkenburg/brunt-api";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
})
