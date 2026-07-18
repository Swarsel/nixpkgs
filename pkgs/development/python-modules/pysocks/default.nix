{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "pysocks";
  version = "1.7.1";

  src = fetchPypi {
    inherit version;
    sha256 = "184sg65mbmih6ljblfsxcmq5js5l7dj3gpn618w9q5dy3rbh921z";
    pname = "PySocks";
  };

  doCheck = false;
  format = "setuptools";

  meta = {
    description = "SOCKS module for Python";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ thoughtpolice ];
  };
}
