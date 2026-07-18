{
  lib,
  fetchFromGitHub,
  # dependencies
  aiohttp,
  asyncio-throttle,
  buildPythonPackage,
  # build-system
  poetry-core,
}:

buildPythonPackage rec {
  pname = "deezer-python-async";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "music-assistant";
    repo = "deezer-python-async";
    tag = "v${version}";
    hash = "sha256-uuAB+SC/ECG50ox/6Bi+94bAt+YZokeQChpDQUAK+zc=";
  };

  doCheck = false; # requires access to the deezer api

  build-system = [
    poetry-core
  ];

  dependencies = [
    aiohttp
    asyncio-throttle
  ];

  pyproject = true;

  pythonImportsCheck = [
    "deezer"
  ];

  meta = {
    description = "Deezer client for python *but async";
    homepage = "https://github.com/music-assistant/deezer-python-async";
    changelog = "https://github.com/music-assistant/deezer-python-async/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
