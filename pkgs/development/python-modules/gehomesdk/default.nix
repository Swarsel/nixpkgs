{
  lib,
  aiohttp,
  beautifulsoup4,
  bidict,
  buildPythonPackage,
  cryptography,
  fetchPypi,
  humanize,
  pytestCheckHook,
  requests,
  setuptools,
  websockets,
}:

buildPythonPackage (finalAttrs: {
  pname = "gehomesdk";
  version = "2026.5.4";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-zKYe7vIXSFbtTqaCLEAHQvuDRGGXqorqfFqVVpBWuJs=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    cryptography
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    beautifulsoup4
    bidict
    humanize
    requests
    websockets
  ];

  pyproject = true;
  pythonImportsCheck = [ "gehomesdk" ];

  meta = {
    description = "Python SDK for GE smart appliances";
    homepage = "https://github.com/simbaja/gehome";
    changelog = "https://github.com/simbaja/gehome/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "gehome-appliance-data";
  };
})
