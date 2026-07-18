{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "online-judge-verify-helper";
  version = "5.6.0";

  src = fetchFromGitHub {
    owner = "online-judge-tools";
    repo = "verification-helper";
    tag = "v${finalAttrs.version}";
    hash = "sha256-sBR9/rf8vpDRbRD8HO2VNmxVckXPmPjUih7ogLRFaW8=";
  };

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
  ];

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    colorlog
    importlab
    online-judge-tools
    pyyaml
    setuptools
    toml
  ];

  # No additional dependencies or network access
  disabledTestPaths = [
    "tests/test_docs.py"
    "tests/test_python.py"
    "tests/test_rust.py"
    "tests/test_stats.py"
    "tests/test_verify.py"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "onlinejudge"
    "onlinejudge_bundle"
    "onlinejudge_verify"
    "onlinejudge_verify_resources"
  ];

  meta = {
    description = "Testing framework for snippet libraries used in competitive programming";
    homepage = "https://github.com/online-judge-tools/verification-helper";
    changelog = "https://github.com/online-judge-tools/verification-helper/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ toyboot4e ];
    mainProgram = "oj-verify";
  };
})
