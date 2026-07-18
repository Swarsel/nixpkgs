{
  lib,
  aenum,
  aioconsole,
  aiohttp,
  aiohttp-retry,
  buildPythonPackage,
  fetchPypi,
  inflection,
  poetry-core,
  pydantic,
  python-dateutil,
  typing-extensions,
  urllib3,
  websockets,
  zeroconf,
}:

buildPythonPackage (finalAttrs: {
  pname = "mozart-api";
  version = "6.2.0.44.1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-HJKxw49hGjVedjpCzxfbL8v6b6MXXqE96hlL5U64r5Y=";
    pname = "mozart_api";
  };

  # Package has no tests
  doCheck = false;
  build-system = [ poetry-core ];

  dependencies = [
    aioconsole
    aiohttp
    aiohttp-retry
    inflection
    pydantic
    python-dateutil
    typing-extensions
    urllib3
    websockets
    zeroconf
  ];

  pyproject = true;
  pythonImportsCheck = [ "mozart_api" ];

  meta = {
    description = "REST API for the Bang & Olufsen Mozart platform";
    homepage = "https://github.com/bang-olufsen/mozart-open-api";
    changelog = "https://github.com/bang-olufsen/mozart-open-api/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
