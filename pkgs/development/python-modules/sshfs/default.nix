{
  lib,
  stdenv,
  fetchFromGitHub,
  asyncssh,
  bcrypt,
  buildPythonPackage,
  fsspec,
  importlib-metadata,
  mock-ssh-server,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "sshfs";
  version = "2025.11.0";

  src = fetchFromGitHub {
    owner = "fsspec";
    repo = "sshfs";
    tag = version;
    hash = "sha256-TrFrjORH6VebTBq+OHJUEr55DtjL58/b+qQLpbSU7MU=";
  };

  nativeCheckInputs = [
    importlib-metadata
    mock-ssh-server
    pytest-asyncio
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    asyncssh
    fsspec
  ];

  disabledTests = [
    # Test requires network access
    "test_config_expansions"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # Test fails with sandbox enabled
    "test_checksum"
  ];

  optional-dependencies = {
    bcrypt = [ asyncssh ] ++ asyncssh.optional-dependencies.bcrypt;
    fido2 = [ asyncssh ] ++ asyncssh.optional-dependencies.fido2;
    gssapi = [ asyncssh ] ++ asyncssh.optional-dependencies.gssapi;
    libnacl = [ asyncssh ] ++ asyncssh.optional-dependencies.libnacl;
    pkcs11 = [ asyncssh ] ++ asyncssh.optional-dependencies.pkcs11;
    pyopenssl = [ asyncssh ] ++ asyncssh.optional-dependencies.pyOpenSSL;
  };

  pyproject = true;
  pythonImportsCheck = [ "sshfs" ];

  meta = {
    description = "SSH/SFTP implementation for fsspec";
    homepage = "https://github.com/fsspec/sshfs/";
    changelog = "https://github.com/fsspec/sshfs/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
  };
}
