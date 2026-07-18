{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  setuptools,
  yarl,
}:

buildPythonPackage rec {
  pname = "pydroid-ipcam";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "home-assistant-libs";
    repo = "pydroid-ipcam";
    tag = version;
    hash = "sha256-Z5dWgeXwIRd2iPT2GsWyypHVbaMZ5NUXEBxa8+AZdNk=";
  };

  # Project has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    yarl
  ];

  pyproject = true;
  pythonImportsCheck = [ "pydroid_ipcam" ];

  meta = {
    description = "Python library for Android IP Webcam";
    homepage = "https://github.com/home-assistant-libs/pydroid-ipcam";
    changelog = "https://github.com/home-assistant-libs/pydroid-ipcam/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
