{
  lib,
  buildPythonPackage,
  fetchPypi,
  isPy3k,
}:

buildPythonPackage rec {
  pname = "versiontools";
  version = "1.9.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1xhl6kl7f4srgnw6zw4lr8j2z5vmrbaa83nzn2c9r2m1hwl36sd9";
  };

  doCheck = (!isPy3k);
  format = "setuptools";

  meta = {
    description = "Smart replacement for plain tuple used in __version__";
    homepage = "https://launchpad.net/versiontools";
    license = lib.licenses.lgpl2;
  };
}
