{
  lib,
  buildPythonPackage,
  colorama,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "crayons";
  version = "0.4.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "bd33b7547800f2cfbd26b38431f9e64b487a7de74a947b0fafc89b45a601813f";
  };

  propagatedBuildInputs = [ colorama ];
  format = "setuptools";

  meta = {
    description = "TextUI colors for Python";
    homepage = "https://github.com/kennethreitz/crayons";
    license = lib.licenses.mit;
  };
}
