{
  lib,
  buildPythonPackage,
  charset-normalizer,
  dsinternals,
  fetchPypi,
  flask,
  ldap3,
  ldapdomaindump,
  pyasn1,
  pyasn1-modules,
  pycryptodomex,
  pyopenssl,
  pytestCheckHook,
  setuptools,
  six,
  writeText,
}:

let
  opensslConf = writeText "openssl.conf" ''
    openssl_conf = openssl_init

    [openssl_init]
    providers = provider_sect

    [provider_sect]
    default = default_sect
    legacy = legacy_sect

    [default_sect]
    activate = 1

    [legacy_sect]
    activate = 1
  '';
in
buildPythonPackage rec {
  pname = "impacket";
  version = "0.13.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-7ZHIAra+/2VGr9ImKUK8GhiLRnH7kex1HUah1m0ows8=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    charset-normalizer
    dsinternals
    flask
    ldap3
    ldapdomaindump
    pyasn1
    pyasn1-modules
    pycryptodomex
    pyopenssl
    setuptools
    six
  ];

  disabledTestPaths = [
    # Skip all RPC related tests
    "tests/dcerpc/"
    "tests/SMB_RPC/"
  ];

  makeWrapperArgs = [ "--set-default OPENSSL_CONF ${opensslConf}" ];
  pyproject = true;

  pythonImportsCheck = [
    "impacket"
    "impacket.msada_guids"
  ];

  pythonRelaxDeps = [ "pyopenssl" ];

  meta = {
    description = "Network protocols Constructors and Dissectors";
    homepage = "https://github.com/SecureAuthCorp/impacket";

    changelog =
      "https://github.com/fortra/impacket/releases/tag/impacket_"
      + lib.replaceStrings [ "." ] [ "_" ] version;

    # Modified Apache Software License, Version 1.1
    license = lib.licenses.free;
    maintainers = with lib.maintainers; [ fab ];
  };
}
