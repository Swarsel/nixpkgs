{
  lib,
  buildPythonPackage,
  cython,
  fetchPypi,
  numpy,
}:

buildPythonPackage rec {
  pname = "libmr";
  version = "0.1.9";

  src = fetchPypi {
    inherit pname version;
    sha256 = "43ccd86693b725fa3abe648c8cdcef17ba5fa46b5528168829e5f9b968dfeb70";
    extension = "zip";
  };

  propagatedBuildInputs = [
    numpy
    cython
  ];

  # No tests in the pypi tarball
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "LibMR provides core MetaRecognition and Weibull fitting functionality";
    homepage = "https://github.com/Vastlab/libMR";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ psyanticy ];
  };
}
