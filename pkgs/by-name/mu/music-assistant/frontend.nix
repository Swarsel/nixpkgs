{
  lib,
  buildPythonPackage,
  fetchPypi,
  music-assistant,
  setuptools,
}:

buildPythonPackage rec {
  pname = "music-assistant-frontend";
  version = "2.17.186";

  src = fetchPypi {
    inherit version;
    hash = "sha256-dNGzXDRZuQLRkMY0erjJZE4h26yFP4Fdn9a3K6T0RvM=";
    pname = "music_assistant_frontend";
  };

  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "music_assistant_frontend" ];

  meta = {
    inherit (music-assistant.meta) maintainers;
    description = "Music Assistant frontend";
    homepage = "https://github.com/music-assistant/frontend";
    changelog = "https://github.com/music-assistant/frontend/releases/tag/${version}";
    license = lib.licenses.asl20;
  };
}
