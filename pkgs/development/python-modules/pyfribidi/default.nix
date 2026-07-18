{
  lib,
  stdenv,
  buildPythonPackage,
  fetchPypi,
  isPyPy,
  six,
}:

buildPythonPackage rec {
  pname = "pyfribidi";
  version = "0.12.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "64726a4a56783acdc79c6b9b3a15f16e6071077c897a0b999f3b43f744bc621c";
    extension = "zip";
  };

  patches = lib.optional stdenv.cc.isClang ./pyfribidi-clang.patch;
  propagatedBuildInputs = [ six ];
  disabled = isPyPy;
  format = "setuptools";

  meta = {
    description = "Simple wrapper around fribidi";
    homepage = "https://github.com/pediapress/pyfribidi";
    license = lib.licenses.gpl2;
  };
}
