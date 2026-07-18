{
  lib,
  stdenv,
  buildPythonPackage,
  fetchPypi,
  greenlet,
  pythonAtLeast,
  setuptools,
}:

buildPythonPackage rec {
  pname = "meinheld";
  version = "1.0.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-AIx2k3rCEXzGngMtxpzqn4X8YF3pusFBf0R8QcFqVtY=";
  };

  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.cc.isGNU "-Wno-error=implicit-function-declaration";
  # No tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ greenlet ];
  disabled = pythonAtLeast "3.13";
  pyproject = true;
  pythonImportsCheck = [ "meinheld" ];
  pythonRelaxDeps = [ "greenlet" ];

  meta = {
    description = "High performance asynchronous Python WSGI Web Server";
    homepage = "https://meinheld.org/";
    license = lib.licenses.bsd3;
  };
}
