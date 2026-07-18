{
  lib,
  fetchFromGitHub,
  aiofiles,
  aiohttp,
  aioresponses,
  buildPythonPackage,
  mashumaro,
  pytest-asyncio,
  pytestCheckHook,
  pythonOlder,
  setuptools_80,
}:

buildPythonPackage (finalAttrs: {
  pname = "airos";
  version = "0.6.11";

  src = fetchFromGitHub {
    owner = "CoMPaTech";
    repo = "python-airos";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mCa2Mabw+Y5QAdiFquw7NP3K9HgDj+wZJbln2ugTp0Q=";
  };

  nativeCheckInputs = [
    aiofiles
    aioresponses
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools_80 ];

  dependencies = [
    aiohttp
    mashumaro
  ];

  disabled = pythonOlder "3.13";
  pyproject = true;
  pythonImportsCheck = [ "airos" ];

  meta = {
    description = "Ubiquity airOS module(s) for Python 3";
    homepage = "https://github.com/CoMPaTech/python-airos";
    changelog = "https://github.com/CoMPaTech/python-airos/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
})
