{
  lib,
  buildPythonPackage,
  fetchPypi,
  tkinter,
}:

buildPythonPackage rec {
  pname = "pmw";
  version = "2.1.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-lIQSRXz8zwx3XdCOCRP7APkIlqM8eXN9VxxzEq6vVcY=";
    pname = "Pmw";
  };

  propagatedBuildInputs = [ tkinter ];
  # Disable tests due to their xserver requirement
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Toolkit for building high-level compound widgets in Python using the Tkinter module";
    homepage = "https://pmw.sourceforge.net/";
    license = lib.licenses.mit;
  };
}
