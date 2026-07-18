{
  lib,
  buildPythonPackage,
  fetchPypi,
  passlib,
  pyparsing,
  six,
  twisted,
  zope-interface,
}:

buildPythonPackage rec {
  pname = "ldaptor";
  version = "21.2.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-jEnrGTddSqs+W4NYYGFODLF+VrtaIOGHSAj6W+xno1g=";
  };

  propagatedBuildInputs = [
    passlib
    pyparsing
    six
    twisted
    zope-interface
  ]
  ++ twisted.optional-dependencies.tls;

  # Test creates an excessive amount of temporary files (order of millions).
  # Cleaning up those files already took over 15 hours already on my zfs
  # filesystem and is not finished yet.
  doCheck = false;
  nativeCheckInputs = [ twisted ];

  checkPhase = ''
    trial -j$NIX_BUILD_CORES ldaptor
  '';

  format = "setuptools";

  meta = {
    description = "Pure-Python Twisted library for LDAP";
    homepage = "https://github.com/twisted/ldaptor";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
