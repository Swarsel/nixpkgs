{
  lib,
  stdenv,
  fetchFromGitLab,
  buildPythonPackage,
  charset-normalizer,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "python-debian";
  version = "1.1.0";

  src = fetchFromGitLab {
    owner = "python-debian-team";
    repo = "python-debian";
    tag = finalAttrs.version;
    hash = "sha256-v2b9xobxCrSz0tOEBo6awmQuTyykyJlsryPBMRU9EmM=";
    domain = "salsa.debian.org";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    charset-normalizer
  ];

  disabledTestPaths = lib.optionals stdenv.hostPlatform.isDarwin [
    "tests/test_debfile.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "debian" ];

  meta = {
    description = "Debian package related modules";
    homepage = "https://salsa.debian.org/python-debian-team/python-debian";
    changelog = "https://salsa.debian.org/python-debian-team/python-debian/-/blob/master/debian/changelog";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ nickcao ];
  };
})
