{
  lib,
  fetchFromGitHub,
  argon2-cffi,
  buildPythonPackage,
  keyring,
  pycryptodome,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "keyrings-cryptfile";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "frispete";
    repo = "keyrings.cryptfile";
    tag = "v${version}";
    hash = "sha256-cDXx0s3o8hNqgzX4oNkjGhNcaUX5vi1uN2d9sdbiZwk=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  build-system = [ setuptools ];

  dependencies = [
    argon2-cffi
    keyring
    pycryptodome
  ];

  disabledTests = [
    # correct raise `ValueError`s which pytest fails to catch for some reason:
    "test_empty_username"
    # TestEncryptedFileKeyring::test_file raises 'ValueError: Incorrect Password' for some reason, maybe mock related:
    "TestEncryptedFileKeyring"
  ];

  pyproject = true;
  pythonImportsCheck = [ "keyrings.cryptfile" ];

  meta = {
    description = "Encrypted file keyring backend";
    homepage = "https://github.com/frispete/keyrings.cryptfile";
    changelog = "https://github.com/frispete/keyrings.cryptfile/blob/v${version}/CHANGES.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.bbjubjub ];
    mainProgram = "cryptfile-convert";
  };
}
