{
  lib,
  fetchFromGitLab,
  asn1crypto,
  attrs,
  beautifulsoup4,
  buildPythonPackage,
  pyfakefs,
  pytestCheckHook,
  python-dateutil,
  setuptools,
  setuptools-scm,
  urllib3,
}:

buildPythonPackage (finalAttrs: {
  pname = "cryptodatahub";
  version = "1.2.1";

  src = fetchFromGitLab {
    owner = "coroner";
    repo = "cryptodatahub";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Zu8E3k6jHFK+IIHWOalmdv/mPGhT7JjgjFkGiLxA4iI=";
  };

  nativeCheckInputs = [
    beautifulsoup4
    pyfakefs
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    asn1crypto
    attrs
    python-dateutil
    urllib3
  ];

  disabledTestPaths = [
    # failing tests
    "test/updaters/test_common.py"
    # Tests require network access
    "test/common/test_utils.py"
  ];

  disabledTests = [
    # fails due to certificate expiry
    # see https://gitlab.com/coroner/cryptodatahub/-/work_items/38
    "test_validity"
    # pytest incorrectly collects abstract base classes
    "TestClasses"
  ];

  pyproject = true;
  pythonImportsCheck = [ "cryptodatahub" ];

  meta = {
    description = "Repository of cryptography-related data";
    homepage = "https://gitlab.com/coroner/cryptodatahub";
    changelog = "https://gitlab.com/coroner/cryptodatahub/-/blob/${finalAttrs.src.tag}/CHANGELOG.rst";
    license = lib.licenses.mpl20;
    teams = with lib.teams; [ ngi ];
  };
})
