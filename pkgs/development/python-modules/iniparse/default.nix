{
  lib,
  buildPythonPackage,
  fetchPypi,
  python,
  six,
}:

buildPythonPackage rec {
  pname = "iniparse";
  version = "0.5";

  src = fetchPypi {
    inherit pname version;
    sha256 = "932e5239d526e7acb504017bb707be67019ac428a6932368e6851691093aa842";
  };

  propagatedBuildInputs = [ six ];
  # Does not install tests
  doCheck = false;

  checkPhase = ''
    ${python.interpreter} runtests.py
  '';

  format = "setuptools";

  meta = {
    description = "Accessing and Modifying INI files";
    homepage = "https://github.com/candlepin/python-iniparse";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
