{
  lib,
  buildPythonPackage,
  fetchPypi,
  numpy,
  pytools,
}:

buildPythonPackage rec {
  pname = "genpy";
  version = "2022.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-FGZbQlUgbJjnuiDaKS/vVlraMVmFF1cAQk7S3aPWXx4=";
  };

  propagatedBuildInputs = [
    pytools
    numpy
  ];

  format = "setuptools";

  meta = {
    description = "C/C++ source generation from an AST";
    homepage = "https://github.com/inducer/genpy";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
