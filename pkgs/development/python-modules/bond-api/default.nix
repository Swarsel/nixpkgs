{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "bond-api";
  version = "0.1.18";

  src = fetchFromGitHub {
    owner = "prystupa";
    repo = "bond-api";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+87/j94eHyW3EMMBK+aXaNTVoNxsixeLusyBsPWa9yM=";
  };

  nativeCheckInputs = [
    aioresponses
    pytest-asyncio
    pytestCheckHook
  ];

  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ aiohttp ];
  pyproject = true;
  pythonImportsCheck = [ "bond_api" ];

  meta = {
    description = "Asynchronous Python wrapper library over Bond Local API";
    homepage = "https://github.com/prystupa/bond-api";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
})
