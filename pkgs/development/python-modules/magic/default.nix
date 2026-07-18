{
  lib,
  stdenv,
  buildPythonPackage,
  pkgs,
}:

buildPythonPackage {
  inherit (pkgs.file) pname version src;
  buildInputs = [ pkgs.file ];
  preConfigure = "cd python";
  # No test suite
  doCheck = false;
  format = "setuptools";

  patchPhase = ''
    substituteInPlace python/magic.py --replace "find_library('magic')" "'${pkgs.file}/lib/libmagic${stdenv.hostPlatform.extensions.sharedLibrary}'"
  '';

  meta = {
    description = "Python wrapper around libmagic";
    homepage = "http://www.darwinsys.com/file/";
    license = lib.licenses.lgpl2;
  };
}
