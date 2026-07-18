{
  lib,
  stdenv,
  fetchFromGitHub,
  asn1crypto,
  badldap,
  buildPythonPackage,
  certipy,
  cryptography,
  dnspython,
  hatchling,
  kerbad,
  pytestCheckHook,
  winacl,
}:

buildPythonPackage (finalAttrs: {
  pname = "bloodyad";
  version = "2.5.4";

  src = fetchFromGitHub {
    owner = "CravateRouge";
    repo = "bloodyAD";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6ZSJTupjVhvyU9G/eePJiXk16w9HwpsOFwdwTSLb7tU=";
  };

  # Upstream provides two package scripts: bloodyad and bloodyAD,
  # but this causes a FileAlreadyExists error during installation
  # on Darwin (case-insensitive filesystem).
  # https://github.com/CravateRouge/bloodyAD/issues/99
  postPatch = lib.optionals stdenv.hostPlatform.isDarwin ''
    substituteInPlace pyproject.toml \
      --replace-fail "bloodyAD = \"bloodyAD.main:main\"" ""
  '';

  nativeCheckInputs = [
    certipy
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    asn1crypto
    badldap
    cryptography
    dnspython
    kerbad
    winacl
  ];

  disabledTestPaths = [
    # TypeError: applyFormatters() takes 1 positional argument but 2 were given
    # https://github.com/CravateRouge/bloodyAD/issues/98
    "tests/test_formatters.py"
  ];

  disabledTests = [
    # Tests require network access
    "test_kerberos_authentications"
    "test_01AuthCreateUser"
    "test_02SearchAndGetChildAndGetWritable"
    "test_03UacOwnerGenericShadowGroupPasswordDCSync"
    "test_04ComputerRbcdGetSetAttribute"
    "test_06AddRemoveGetDnsRecord"
    "test_certificate_authentications"
    "test_04ComputerRbcdRestoreGetSetAttribute"
  ];

  pyproject = true;
  pythonImportsCheck = [ "bloodyAD" ];
  pythonRelaxDeps = [ "cryptography" ];

  pythonRemoveDeps = [
    "kerbad"
    "badldap"
  ];

  meta = {
    description = "Module for Active Directory Privilege Escalations";
    homepage = "https://github.com/CravateRouge/bloodyAD";
    changelog = "https://github.com/CravateRouge/bloodyAD/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
