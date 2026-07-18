{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "ha-ffmpeg";
  version = "3.2.2";

  src = fetchFromGitHub {
    owner = "home-assistant-libs";
    repo = "ha-ffmpeg";
    tag = version;
    hash = "sha256-TbSoKoOiLx3O7iykiTri5GBHGj7WoB8iSCpFIrV4ZgU=";
  };

  # only manual tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;

  pythonImportsCheck = [
    "haffmpeg.camera"
    "haffmpeg.sensor"
    "haffmpeg.tools"
  ];

  pythonRemoveDeps = [
    "async_timeout"
  ];

  meta = {
    description = "Library for Home Assistant to handle ffmpeg";
    homepage = "https://github.com/home-assistant-libs/ha-ffmpeg/";
    changelog = "https://github.com/home-assistant-libs/ha-ffmpeg/releases/tag/${version}";
    license = lib.licenses.bsd3;
    teams = [ lib.teams.home-assistant ];
  };
}
