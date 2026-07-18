{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cacert,
  cryptography,
  pytest-mock,
  pytestCheckHook,
  setuptools,
  six,
}:

buildPythonPackage (finalAttrs: {
  pname = "cert-chain-resolver";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "rkoopmans";
    repo = "python-certificate-chain-resolver";
    tag = finalAttrs.version;
    hash = "sha256-DWE+mR7EO5ohuRAR0WC40GBY7HpwXIpU0hhVUnWNRno=";
  };

  env.SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

  nativeCheckInputs = [
    pytestCheckHook
    pytest-mock
    six
  ];

  build-system = [ setuptools ];
  dependencies = [ cryptography ];

  disabledTests = [
    # Tests require network access
    "test_cert_returns_completed_chain"
    "test_display_flag_is_properly_formatted"
    "test_display_flag_includes_warning_when_root_was_requested_but_not_found"
  ];

  pyproject = true;
  pythonImportsCheck = [ "cert_chain_resolver" ];

  meta = {
    description = "Resolve / obtain the certificate intermediates of a x509 certificate";
    homepage = "https://github.com/rkoopmans/python-certificate-chain-resolver";
    changelog = "https://github.com/rkoopmans/python-certificate-chain-resolver/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ veehaitch ];
    mainProgram = "cert-chain-resolver";
  };
})
