{
  lib,
  fetchFromGitLab,
  asn1crypto,
  attrs,
  buildPythonPackage,
  cryptodatahub,
  fetchpatch2,
  pyfakefs,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  urllib3,
}:

buildPythonPackage (finalAttrs: {
  pname = "cryptoparser";
  version = "1.2.1";

  src = fetchFromGitLab {
    owner = "coroner";
    repo = "cryptoparser";
    tag = "v${finalAttrs.version}";
    hash = "sha256-thhpXfLH5yB3pMUKFrMUJ8+8IGchF813ApKUrN+UuZA=";
  };

  patches = [
    (fetchpatch2 {
      hash = "sha256-T8dK6OMR41XUMrZ6B7ZybEtljZJOR2QbCiZl04dT3wA=";
      url = "https://gitlab.com/coroner/cryptoparser/-/merge_requests/2.diff";
    })
  ];

  env.PYTHONDONTWRITEBYTECODE = 1;

  nativeCheckInputs = [
    pyfakefs
    pytestCheckHook
  ];

  postInstall = ''
    find $out -name __pycache__ -type d | xargs rm -rv
  '';

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    asn1crypto
    attrs
    cryptodatahub
    urllib3
  ];

  disabledTests = [
    # pytest incorrectly collects abstract base classes
    "TestCasesBasesHttpHeader"
  ];

  pyproject = true;
  pythonImportsCheck = [ "cryptoparser" ];

  meta = {
    description = "Security protocol parser and generator";
    homepage = "https://gitlab.com/coroner/cryptoparser";
    changelog = "https://gitlab.com/coroner/cryptoparser/-/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mpl20;
    teams = with lib.teams; [ ngi ];
  };
})
