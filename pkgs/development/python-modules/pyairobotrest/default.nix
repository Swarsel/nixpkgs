{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyairobotrest";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "mettolen";
    repo = "pyairobotrest";
    tag = finalAttrs.version;
    hash = "sha256-PYrxQgWlcF7a/gwbJLL1JFrM+5HM3nQco9Yzy3qV1HM=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyairobotrest" ];

  meta = {
    description = "Python library for controlling Airobot TE1 thermostats via local REST API";
    homepage = "https://github.com/mettolen/pyairobotrest";
    changelog = "https://github.com/mettolen/pyairobotrest/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dotlambda ];
  };
})
