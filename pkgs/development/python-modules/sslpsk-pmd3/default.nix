{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  openssl,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "sslpsk-pmd3";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "doronz88";
    repo = "sslpsk-pmd3";
    tag = "v${version}";
    hash = "sha256-ZOPrMZhtHIpE7QMEYGti+ZjqVv93jzb74rG5Fwhjgyw=";
  };

  buildInputs = [
    openssl
  ];

  # tests are dysfunctional
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
  ];

  preCheck = ''
    # import from $out
    mv sslpsk_pmd3 src
  '';

  build-system = [
    setuptools
    setuptools-scm
  ];

  pyproject = true;
  pythonImportsCheck = [ "sslpsk_pmd3" ];

  meta = {
    description = "Adds TLS-PSK support to the Python ssl package";
    homepage = "https://github.com/doronz88/sslpsk-pmd3";
    changelog = "https://github.com/doronz88/sslpsk-pmd3/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.dotlambda ];
  };
}
