{
  lib,
  stdenv,
  alsa-lib,
  buildPythonPackage,
  cython_0,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "rtmidi-python";
  version = "0.2.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1wpcaxfpbmsjc78g8841kpixr0a3v6zn0ak058s3mm25kcysp4m0";
  };

  postPatch = ''
    rm rtmidi_python.cpp
  '';

  nativeBuildInputs = [ cython_0 ];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ alsa-lib ];
  # package has no tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "rtmidi_python" ];
  setupPyBuildFlags = [ "--from-cython" ];

  meta = {
    description = "Python wrapper for RtMidi";
    homepage = "https://github.com/superquadratic/rtmidi-python";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
