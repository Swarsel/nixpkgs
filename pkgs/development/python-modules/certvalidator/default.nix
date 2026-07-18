{
  lib,
  fetchFromGitHub,
  asn1crypto,
  buildPythonPackage,
  cacert,
  oscrypto,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "certvalidator";
  version = "0.11.1";

  src = fetchFromGitHub {
    owner = "wbond";
    repo = "certvalidator";
    tag = finalAttrs.version;
    hash = "sha256-yVF7t4FuU3C9fDg67JeM7LWZZh/mv5F4EKmjlO4AuBY=";
  };

  nativeCheckInputs = [ cacert ];

  checkPhase = ''
    # Tests are run with a custom executor/loader
    # The regex to skip specific tests relies on negative lookahead of regular expressions
    # We're skipping the few tests that rely on the network, fetching CRLs, OCSP or remote certificates
    python -c 'import dev.tests; dev.tests.run("^(?!.*test_(basic_certificate_validator_tls|fetch|revocation|build_path)).*$")'
  '';

  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    asn1crypto
    oscrypto
  ];

  pyproject = true;
  pythonImportsCheck = [ "certvalidator" ];

  meta = {
    description = "Validates X.509 certificates and paths";
    homepage = "https://github.com/wbond/certvalidator";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ baloo ];
  };
})
