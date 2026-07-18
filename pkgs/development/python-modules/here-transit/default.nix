{
  lib,
  fetchFromGitHub,
  aiohttp,
  aresponses,
  async-timeout,
  buildPythonPackage,
  hatchling,
  pytest-asyncio,
  pytestCheckHook,
  yarl,
}:

buildPythonPackage rec {
  pname = "here-transit";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "eifinger";
    repo = "here_transit";
    rev = "v${version}";
    hash = "sha256-fORg1iqRcD75Is1EW9XeAu8astibypmnNXo3vHduQdk=";
  };

  postPatch = ''
    sed -i "/^addopts/d" pyproject.toml
  '';

  nativeCheckInputs = [
    aresponses
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    aiohttp
    async-timeout
    yarl
  ];

  pyproject = true;
  pythonImportsCheck = [ "here_transit" ];

  meta = {
    description = "Asynchronous Python client for the HERE Routing V8 API";
    homepage = "https://github.com/eifinger/here_transit";
    changelog = "https://github.com/eifinger/here_transit/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
