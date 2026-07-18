{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  freezegun,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
  svgwrite,
}:

buildPythonPackage rec {
  pname = "irm-kmi-api";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "jdejaegh";
    repo = "irm-kmi-api";
    tag = version;
    hash = "sha256-RJMIXisgG4ybynsm7kCrN8zOU0EJv7a1Q74l+edxH/E=";
  };

  nativeCheckInputs = [
    freezegun
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    svgwrite
  ];

  pyproject = true;
  pythonImportsCheck = [ "irm_kmi_api" ];

  meta = {
    description = "Retrieve data from the Belgian Royal Meteorological Institute";
    homepage = "https://github.com/jdejaegh/irm-kmi-api";
    changelog = "https://github.com/jdejaegh/irm-kmi-api/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dotlambda ];
  };
}
