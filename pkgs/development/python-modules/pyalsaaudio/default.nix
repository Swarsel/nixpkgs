{
  lib,
  alsa-lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "pyalsaaudio";
  version = "0.11.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-p4qdyjNSSyyQZLNOIfWrh0JyMTzzJKmndZLzlqXg/dw=";
  };

  buildInputs = [
    alsa-lib
  ];

  # Unit tests exist in test.py, but they require hardware (and therefore /dev) access.
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "alsaaudio" ];

  meta = {
    description = "ALSA wrappers for Python";
    homepage = "https://github.com/larsimmisch/pyalsaaudio";
    changelog = "https://github.com/larsimmisch/pyalsaaudio/blob/${version}/CHANGES.md";
    license = lib.licenses.psfl;
    maintainers = with lib.maintainers; [ timschumi ];
  };
}
