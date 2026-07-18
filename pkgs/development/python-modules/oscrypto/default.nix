{
  lib,
  stdenv,
  fetchFromGitHub,
  asn1crypto,
  buildPythonPackage,
  fetchpatch,
  openssl,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "oscrypto";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "wbond";
    repo = "oscrypto";
    rev = version;
    hash = "sha256-CmDypmlc/kb6ONCUggjT1Iqd29xNSLRaGh5Hz36dvOw=";
  };

  patches = [
    ./support-openssl-3.0.10.patch

    (fetchpatch {
      hash = "sha256-lQGoPM7EicwCPWapEDkqWEqMqXk4tijiImxndcDFqY4=";
      # backport removal of imp module usage
      url = "https://github.com/wbond/oscrypto/commit/3865f5d528740aa1205d16ddbee84c5b48aeb078.patch";
    })
  ];

  postPatch = ''
    for file in oscrypto/_openssl/_lib{crypto,ssl}_c{ffi,types}.py; do
      substituteInPlace $file \
        --replace "get_library('crypto', 'libcrypto.dylib', '42')" "'${openssl.out}/lib/libcrypto${stdenv.hostPlatform.extensions.sharedLibrary}'" \
        --replace "get_library('ssl', 'libssl', '44')" "'${openssl.out}/lib/libssl${stdenv.hostPlatform.extensions.sharedLibrary}'"
    done
  '';

  propagatedBuildInputs = [ asn1crypto ];
  doCheck = !stdenv.hostPlatform.isDarwin;
  nativeCheckInputs = [ pytestCheckHook ];

  disabledTests = [
    # Tests require network access
    "TLSTests"
    "TrustListTests"
  ];

  format = "setuptools";
  pythonImportsCheck = [ "oscrypto" ];

  meta = {
    description = "Encryption library for Python";
    homepage = "https://github.com/wbond/oscrypto";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
