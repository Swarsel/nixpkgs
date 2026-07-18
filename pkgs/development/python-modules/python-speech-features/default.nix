{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  pytestCheckHook,
  scipy,
  setuptools,
}:

buildPythonPackage rec {
  pname = "python-speech-features";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "jameslyons";
    repo = "python_speech_features";
    rev = version;
    hash = "sha256-IAQujxQ5hOXFNOIEhWsGOTeWqxyBmqL5HSVD4KYEn3U=";
  };

  nativeBuildInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    numpy
    scipy
  ];

  pyproject = true;

  pythonImportsCheck = [
    "python_speech_features"
  ];

  meta = {
    description = "Common speech features for ASR including MFCCs and filterbank energies";
    homepage = "https://github.com/jameslyons/python_speech_features";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
