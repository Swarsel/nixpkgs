{
  lib,
  fetchFromGitHub,
  aiohttp,
  async-timeout,
  buildPythonPackage,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
  slixmpp,
}:

buildPythonPackage rec {
  pname = "aioharmony";
  version = "1.0.8";

  src = fetchFromGitHub {
    owner = "Harmony-Libs";
    repo = "aioharmony";
    tag = "v${version}";
    hash = "sha256-7K/I71yonmAqLp12Hk8e72BBfF/sez1cFdQbnixDdbg=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    async-timeout
    slixmpp
  ];

  pyproject = true;

  pythonImportsCheck = [
    "aioharmony.harmonyapi"
    "aioharmony.harmonyclient"
  ];

  meta = {
    description = "Python library for interacting the Logitech Harmony devices";
    homepage = "https://github.com/Harmony-Libs/aioharmony";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ oro ];
    mainProgram = "aioharmony";
  };
}
