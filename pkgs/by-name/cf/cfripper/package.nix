{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "cfripper";
  version = "1.21.0";

  src = fetchFromGitHub {
    owner = "Skyscanner";
    repo = "cfripper";
    tag = "v${finalAttrs.version}";
    hash = "sha256-psuUG8Kk+pl9Qv9vpH7yCn2X6leciftgFN1Ft+zEgtg=";
  };

  nativeBuildInputs = [
  ];

  nativeCheckInputs = with python3.pkgs; [
    moto
    pytestCheckHook
  ];

  build-system = with python3.pkgs; [
    setuptools
    setuptools-scm
  ];

  dependencies = with python3.pkgs; [
    boto3
    cfn-flip
    click
    pluggy
    pycfmodel
    pydash
    pyyaml
    setuptools
  ];

  disabledTestPaths = [
    # Tests are failing
    "tests/test_boto3_client.py"
    "tests/config/test_pluggy.py"
  ];

  disabledTests = [
    # Assertion fails
    "test_multiple_resources_with_wildcard_resources_are_detected"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "cfripper"
  ];

  pythonRelaxDeps = [
    "pluggy"
  ];

  meta = {
    description = "Tool for analysing CloudFormation templates";
    homepage = "https://github.com/Skyscanner/cfripper";
    changelog = "https://github.com/Skyscanner/cfripper/releases/tag/${finalAttrs.src.tag}";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "cfripper";
  };
})
