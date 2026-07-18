{
  lib,
  buildPythonPackage,
  cython,
  fetchPypi,
  glib,
  libsmf,
  pkg-config,
  pytest,
}:

buildPythonPackage rec {
  pname = "pysmf";
  version = "0.1.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "10i7vvvdx6c3gl4afsgnpdanwgzzag087zs0fxvfipnqknazj806";
  };

  nativeBuildInputs = [
    pkg-config
    pytest
    cython
  ];

  buildInputs = [
    libsmf
    glib
  ];

  format = "setuptools";

  postUnpack = ''
    rm $sourceRoot/src/smf.c
  '';

  meta = {
    description = "Python extension module for reading and writing Standard MIDI Files, based on libsmf";
    homepage = "https://das.nasophon.de/pysmf/";
    license = lib.licenses.bsd2;
    maintainers = [ ];
  };
}
