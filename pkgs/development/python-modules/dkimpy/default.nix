{
  lib,
  authres,
  buildPythonPackage,
  dnspython,
  fetchPypi,
  openssl,
  pynacl,
  pytest,
  python,
}:

buildPythonPackage rec {
  pname = "dkimpy";
  version = "1.1.8";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-tfYPtHu/XY12LxNLzqDDiOumtJg0KmgqIfFoZUUJS3c=";
  };

  propagatedBuildInputs = [
    openssl
    dnspython
    pynacl
    authres
  ];

  nativeCheckInputs = [ pytest ];

  checkPhase = ''
    ${python.interpreter} ./test.py
  '';

  format = "setuptools";

  patchPhase = ''
    substituteInPlace dkim/dknewkey.py --replace \
      /usr/bin/openssl ${openssl}/bin/openssl
  '';

  meta = {
    description = "DKIM + ARC email signing/verification tools + Python module";

    longDescription = ''
      Python module that implements DKIM (DomainKeys Identified Mail) email
      signing and verification. It also provides a number of convenient tools
      for command line signing and verification, as well as generating new DKIM
      records. This version also supports the experimental Authenticated
      Received Chain (ARC) protocol.
    '';

    homepage = "https://launchpad.net/dkimpy";
    license = lib.licenses.bsd3;
  };
}
