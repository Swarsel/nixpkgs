{
  lib,
  stdenv,
  buildPythonPackage,
  cffi,
  fetchPypi,
  numpy,
  portaudio,
  replaceVars,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "sounddevice";
  version = "0.5.5";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Ikh7ZRmMtb8iCHVRBbUk94rRc+Wra0Rb2rHJifZpjfM=";
  };

  patches = [
    (replaceVars ./fix-portaudio-library-path.patch {
      portaudio = "${portaudio}/lib/libportaudio${stdenv.hostPlatform.extensions.sharedLibrary}";
    })
  ];

  nativeBuildInputs = [ cffi ];
  # No tests included nor upstream available.
  doCheck = false;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    cffi
    numpy
    portaudio
  ];

  pyproject = true;
  pythonImportsCheck = [ "sounddevice" ];

  meta = {
    description = "Play and Record Sound with Python";
    homepage = "https://python-sounddevice.readthedocs.io/";
    changelog = "https://github.com/spatialaudio/python-sounddevice/releases/tag/${version}";
    license = with lib.licenses; [ mit ];
  };
}
