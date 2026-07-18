{
  lib,
  stdenv,
  fetchFromGitHub,
  bcrypt,
  buildPythonPackage,
  openssl,
  pyopenssl,
  pytestCheckHook,
  python-gnupg,
  replaceVars,
  requests,
}:

buildPythonPackage rec {
  pname = "proton-client";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "ProtonMail";
    repo = "proton-python-client";
    rev = version;
    hash = "sha256-mhPq9O/LCu3+E1jKlaJmrI8dxbA9BIwlc34qGwoxi5g=";
  };

  patches = [
    # Patches library by fixing the openssl path
    (replaceVars ./0001-OpenSSL-path-fix.patch {
      ext = stdenv.hostPlatform.extensions.sharedLibrary;
      openssl = openssl.out;
    })
  ];

  buildInputs = [ openssl ];

  propagatedBuildInputs = [
    bcrypt
    pyopenssl
    python-gnupg
    requests
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  disabledTests = [
    #ValueError: Invalid modulus
    "test_modulus_verification"
    # bcrypt 5.0 rejects test fixture password longer than 72 bytes
    "test_compute_v"
    "test_generate_v"
    "test_srp"
  ];

  format = "setuptools";
  pythonImportsCheck = [ "proton" ];

  meta = {
    description = "Python Proton client module";
    homepage = "https://github.com/ProtonMail/proton-python-client";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
}
