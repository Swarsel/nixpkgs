{
  lib,
  aiohttp,
  buildPythonPackage,
  fetchPypi,
  furl,
  hatchling,
  pytest-asyncio,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "mvg";
  version = "1.6.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-jpk6DUaQYtL7OHDOznhgAp0N8qao0wQI5benfPXwhJI=";
  };

  # tests require network access
  doCheck = false;

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    aiohttp
    furl
  ];

  pyproject = true;
  pythonImportsCheck = [ "mvg" ];

  meta = {
    description = "An unofficial interface to timetable information of the Münchner Verkehrsgesellschaft (MVG)";
    homepage = "https://github.com/mondbaron/mvg";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
