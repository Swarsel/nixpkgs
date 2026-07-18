{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "soundcloudpy";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "music-assistant";
    repo = "soundcloudpy";
    tag = finalAttrs.version;
    hash = "sha256-NuL6VIAssvYiGWqioMtf3Brw/G8Vt2P4/57l3k3db9g=";
  };

  # has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
  ];

  pyproject = true;
  pythonImportsCheck = [ "soundcloudpy" ];

  meta = {
    description = "Client for async connection to the Soundcloud api";
    homepage = "https://github.com/music-assistant/SoundcloudPy";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
  };
})
