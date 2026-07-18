{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "pyrss2gen";
  version = "1.1";

  src = fetchPypi {
    inherit version;
    sha256 = "1rvf5jw9hknqz02rp1vg8abgb1lpa0bc65l7ylmlillqx7bswq3r";
    pname = "PyRSS2Gen";
  };

  # No tests in archive
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Library for generating RSS 2.0 feeds";
    homepage = "http://www.dalkescientific.om/Python/PyRSS2Gen.html";
    license = lib.licenses.bsd2;
    maintainers = [ ];
  };
}
