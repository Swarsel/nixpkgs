{
  lib,
  buildPythonPackage,
  fetchPypi,
  isPyPy,
  pkgs,
}:

buildPythonPackage rec {
  pname = "pyaudio";
  version = "0.2.14";

  src = fetchPypi {
    inherit version;
    hash = "sha256-eN//OHm0mU0fT8ZIVkald1XG7jwZZHpJH3kKCJW9L4c=";
    pname = "PyAudio";
  };

  buildInputs = [ pkgs.portaudio ];
  disabled = isPyPy;
  format = "setuptools";

  meta = {
    description = "Python bindings for PortAudio";
    homepage = "https://people.csail.mit.edu/hubert/pyaudio/";
    license = lib.licenses.mit;
  };
}
