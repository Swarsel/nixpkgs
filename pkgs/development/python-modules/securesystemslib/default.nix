{
  lib,
  fetchFromGitHub,
  # hsm
  asn1crypto,
  # azurekms
  azure-identity,
  azure-keyvault-keys,
  # awskms
  boto3,
  botocore,
  buildPythonPackage,
  cryptography,
  # tests
  ed25519,
  # gcpkms
  google-cloud-kms,
  # build-system
  hatchling,
  # pynacl
  pynacl,
  # optional-dependencies
  # PySPX
  pyspx,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "securesystemslib";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "secure-systems-lab";
    repo = "securesystemslib";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XOE690DKeAMP2KycW+fdYs/KGWqwZCZz/9PiAa6tJbw=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"hatchling==1.29.0"' '"hatchling"'
  '';

  nativeCheckInputs = [
    ed25519
    pytestCheckHook
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  build-system = [ hatchling ];

  disabledTestPaths = [
    # pykcs11 is not available
    "tests/test_hsm_signer.py"
    # Ignore vendorized tests
    "securesystemslib/_vendor/"
  ];

  optional-dependencies = {
    PySPX = [ pyspx ];

    awskms = [
      boto3
      botocore
      cryptography
    ];

    azurekms = [
      azure-identity
      azure-keyvault-keys
      cryptography
    ];

    crypto = [ cryptography ];

    gcpkms = [
      cryptography
      google-cloud-kms
    ];

    hsm = [
      asn1crypto
      cryptography
      #   pykcs11
    ];

    pynacl = [ pynacl ];
    # Circular dependency
    # sigstore = [
    #   sigstore
    # ];
  };

  pyproject = true;
  pythonImportsCheck = [ "securesystemslib" ];

  meta = {
    description = "Cryptographic and general-purpose routines";
    homepage = "https://github.com/secure-systems-lab/securesystemslib";
    changelog = "https://github.com/secure-systems-lab/securesystemslib/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
