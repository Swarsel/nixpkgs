{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  mashumaro,
  python-socketio,
  setuptools,
}:

buildPythonPackage rec {
  pname = "aioaudiobookshelf";
  version = "0.1.24";

  src = fetchFromGitHub {
    owner = "music-assistant";
    repo = "aioaudiobookshelf";
    tag = version;
    hash = "sha256-rVHkmfcEtnQPHb6s8KeNRToDhloDcNnqBjPyTUgIygc=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    aiohttp
    mashumaro
    python-socketio
  ];

  pyproject = true;

  pythonImportsCheck = [
    "aioaudiobookshelf"
  ];

  meta = {
    description = "Async python library to interact with Audiobookshelf";
    homepage = "https://github.com/music-assistant/aioaudiobookshelf";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
