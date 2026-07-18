{
  lib,
  appdirs,
  asn1crypto,
  buildPythonPackage,
  cffi,
  cryptography,
  fetchPypi,
  furl,
  idna,
  orderedmultidict,
  packaging,
  peewee,
  py,
  pyasn1,
  pycparser,
  pyparsing,
  pyscrypt,
  pytest,
  python-dateutil,
  pytz,
  requests,
  six,
  vobject,
}:

buildPythonPackage rec {
  pname = "etesync";
  version = "0.12.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "f20f7e9922ee789c4b71379676ebfe656b675913fe524f2ee722e1b9ef4e5197";
  };

  propagatedBuildInputs = [
    appdirs
    asn1crypto
    cffi
    cryptography
    furl
    idna
    orderedmultidict
    packaging
    peewee
    py
    pyasn1
    pycparser
    pyparsing
    pyscrypt
    python-dateutil
    pytz
    requests
    six
    vobject
  ];

  nativeCheckInputs = [ pytest ];

  checkPhase = ''
    pytest tests/test_collections.py
    pytest tests/test_crypto.py
  '';

  format = "setuptools";

  meta = {
    description = "Python API to interact with an EteSync server";
    homepage = "https://www.etesync.com/";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ valodim ];
  };
}
