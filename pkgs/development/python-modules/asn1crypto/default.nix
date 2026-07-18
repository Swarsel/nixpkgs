{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  pytestCheckHook,
  python,
  # build system
  setuptools,
}:

# Switch version based on python version, as the situation isn't easy:
#   https://github.com/wbond/asn1crypto/issues/269
#   https://github.com/MatthiasValvekens/certomancer/issues/12
let
  provenance =
    if lib.versionOlder python.version "3.12" then
      rec {
        version = "1.5.1";
        hash = "sha256-M8vASxhaJPgkiTrAckxz7gk/QHkrFlNz7fFbnLEBT+M=";
        rev = version;
      }
    else
      {
        version = "1.5.1-unstable-2023-11-03";
        hash = "sha256-11WajEDtisiJsKQjZMSd5sDog3DuuBzf1PcgSY+uuXY=";
        rev = "b763a757bb2bef2ab63620611ddd8006d5e9e4a2";
      };
in

buildPythonPackage {
  inherit (provenance) version;
  pname = "asn1crypto";

  # Pulling from Github to run tests
  src = fetchFromGitHub {
    inherit (provenance) rev hash;
    owner = "wbond";
    repo = "asn1crypto";
  };

  nativeBuildInputs = [ setuptools ];
  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;

  meta = {
    description = "Fast ASN.1 parser and serializer with definitions for private keys, public keys, certificates, CRL, OCSP, CMS, PKCS#3, PKCS#7, PKCS#8, PKCS#12, PKCS#5, X.509 and TSP";
    homepage = "https://github.com/wbond/asn1crypto";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
