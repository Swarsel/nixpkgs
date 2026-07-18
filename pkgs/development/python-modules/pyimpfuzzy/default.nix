{
  lib,
  buildPythonPackage,
  fetchPypi,
  pefile,
  ssdeep,
}:
buildPythonPackage rec {
  pname = "pyimpfuzzy";
  version = "0.5";

  src = fetchPypi {
    inherit pname version;
    sha256 = "da9796df302db4b04a197128637f84988f1882f1e08fdd69bbf9fdc6cfbaf349";
  };

  buildInputs = [ ssdeep ];
  propagatedBuildInputs = [ pefile ];
  # no tests
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "pyimpfuzzy" ];

  meta = {
    description = "Python module which calculates and compares the impfuzzy (import fuzzy hashing)";
    homepage = "https://github.com/JPCERTCC/impfuzzy";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
  };
}
