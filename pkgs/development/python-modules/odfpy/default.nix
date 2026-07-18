{
  lib,
  buildPythonPackage,
  defusedxml,
  fetchPypi,
  pytest,
}:

buildPythonPackage rec {
  pname = "odfpy";
  version = "1.4.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1v1qqk9p12qla85yscq2g413l3qasn6yr4ncyc934465b5p6lxnv";
  };

  propagatedBuildInputs = [ defusedxml ];
  nativeCheckInputs = [ pytest ];

  checkPhase = ''
    pytest
  '';

  format = "setuptools";

  meta = {
    description = "Python API and tools to manipulate OpenDocument files";
    homepage = "https://github.com/eea/odfpy";
    license = lib.licenses.asl20;
  };
}
