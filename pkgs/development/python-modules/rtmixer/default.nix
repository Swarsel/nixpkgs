{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cffi,
  cython,
  pa-ringbuffer,
  portaudio,
  setuptools,
  sounddevice,
}:

buildPythonPackage rec {
  pname = "rtmixer";
  version = "0.1.7";

  src = fetchFromGitHub {
    owner = "spatialaudio";
    repo = "python-rtmixer";
    tag = version;
    hash = "sha256-K5w6XWnDdA5HrzDOMhqinlxrg/09AF6c5CWZEsfVHb4=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cython
    cffi
  ];

  buildInputs = [ portaudio ];
  build-system = [ setuptools ];

  dependencies = [
    cffi
    pa-ringbuffer
    sounddevice
  ];

  pyproject = true;

  meta = {
    description = "Reliable low-latency audio playback and recording with Python, using PortAudio via the sounddevice module";
    homepage = "https://python-rtmixer.readthedocs.io";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ laikq ];
  };
}
