{
  lib,
  fetchFromGitHub,
  SDL2,
  alsa-lib,
  buildPythonPackage,
  gitpython,
  libpcap,
  meson,
  ninja,
  openal,
  pillow,
  pkg-config,
  pygobject3,
  soundtouch,
}:

buildPythonPackage rec {
  pname = "py-desmume";
  version = "0.0.9";

  src = fetchFromGitHub {
    owner = "SkyTemple";
    repo = "py-desmume";
    tag = version;
    hash = "sha256-AlejNgCgncZGCS/xOb3FZiLuEtMsMcprnhnM759aKgY=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    alsa-lib
    gitpython
    libpcap
    openal
    SDL2
    soundtouch
  ];

  propagatedBuildInputs = [
    pillow
    pygobject3
  ];

  doCheck = false; # there are no tests
  format = "setuptools";
  hardeningDisable = [ "format" ];
  pythonImportsCheck = [ "desmume" ];

  meta = {
    description = "Python library to interface with DeSmuME, the Nintendo DS emulator";
    homepage = "https://github.com/SkyTemple/py-desmume";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ marius851000 ];
  };
}
