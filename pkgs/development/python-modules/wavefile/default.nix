{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  libsndfile,
  numpy,
  pyaudio,
  replaceVars,
  setuptools,
}:

buildPythonPackage rec {
  pname = "wavefile";
  version = "1.6.3";

  src = fetchFromGitHub {
    owner = "vokimon";
    repo = "python-wavefile";
    tag = "python-wavefile-${version}";
    hash = "sha256-7pJcdp2abNurTl/pwAEW4QAalK7okMOCwlRPmKLWad4=";
  };

  patches = [
    # Fix check error
    # OSError: libsndfile.so.1: cannot open shared object file: No such file or directory
    (replaceVars ./libsndfile.py.patch {
      libsndfile = "${lib.getLib libsndfile}/lib/libsndfile${stdenv.hostPlatform.extensions.sharedLibrary}";
    })
  ];

  nativeBuildInputs = [ setuptools ];

  buildInputs = [
    pyaudio
    libsndfile
  ];

  propagatedBuildInputs = [ numpy ];
  doCheck = false; # all test files (test/wavefileTest.py) are failing

  nativeCheckInputs = [
    pyaudio
    numpy
    libsndfile
  ];

  pyproject = true;
  pythonImportsCheck = [ "wavefile" ];

  meta = {
    description = "Pythonic libsndfile wrapper to read and write audio files";
    homepage = "https://github.com/vokimon/python-wavefile";
    changelog = "https://github.com/vokimon/python-wavefile#version-history";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
  };
}
