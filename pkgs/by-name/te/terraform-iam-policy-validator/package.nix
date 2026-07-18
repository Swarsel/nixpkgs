{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "terraform-iam-policy-validator";
  version = "0.0.9";

  src = fetchFromGitHub {
    owner = "awslabs";
    repo = "terraform-iam-policy-validator";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RGZqnt2t+aSNGt8Ubi2dzZE04n9Zfkw+T3Zmol/FO+I=";
  };

  nativeCheckInputs = with python3Packages; [ pytestCheckHook ];

  # Tests need to be run relative to a subdir
  preCheck = ''
    pushd iam_check
  '';

  postCheck = ''
    popd
  '';

  build-system = with python3Packages; [ poetry-core ];

  dependencies = with python3Packages; [
    boto3
    pyyaml
  ];

  # Some tests require network
  disabledTestPaths = [ "test/test_accessAnalyzer.py" ];
  pyproject = true;
  pythonImportsCheck = [ "iam_check" ];

  meta = {
    description = "CLI tool that validates AWS IAM Policies in a Terraform template against AWS IAM best practices";
    homepage = "https://github.com/awslabs/terraform-iam-policy-validator";
    changelog = "https://github.com/awslabs/terraform-iam-policy-validator/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jherland ];
    mainProgram = "tf-policy-validator";
  };
})
