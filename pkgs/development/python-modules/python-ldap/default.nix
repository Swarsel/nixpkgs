{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cyrus_sasl,
  # build-system
  distutils,
  jaraco-functools,
  # native dependencies
  openldap,
  pyasn1,
  pyasn1-modules,
  # tests
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "python-ldap";
  version = "3.4.7";

  src = fetchFromGitHub {
    owner = "python-ldap";
    repo = "python-ldap";
    tag = "python-ldap-${finalAttrs.version}";
    hash = "sha256-uSP8c5gid5TBenBaNVdlteHatkctAafz6yFHuIYKiTY=";
  };

  buildInputs = [
    openldap
    cyrus_sasl
  ];

  nativeCheckInputs = [
    jaraco-functools
    pytestCheckHook
  ];

  preCheck = ''
    # Needed by tests to setup a mockup ldap server.
    export BIN="${openldap}/bin"
    export SBIN="${openldap}/bin"
    export SLAPD="${openldap}/libexec/slapd"
    export SCHEMA="${openldap}/etc/schema"
  '';

  __darwinAllowLocalNetworking = true;

  build-system = [
    distutils
    setuptools
  ];

  dependencies = [
    pyasn1
    pyasn1-modules
  ];

  disabledTests = [
    # https://github.com/python-ldap/python-ldap/issues/501
    "test_tls_ext_noca"
  ];

  pyproject = true;

  meta = {
    description = "Python modules for implementing LDAP clients";
    homepage = "https://www.python-ldap.org/";
    changelog = "https://github.com/python-ldap/python-ldap/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.psfl;
    maintainers = [ ];
    downloadPage = "https://github.com/python-ldap/python-ldap";
  };
})
