{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "iamdata";
  version = "0.1.202607081";

  src = fetchFromGitHub {
    owner = "cloud-copilot";
    repo = "iam-data-python";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5bVmdhbO2Gv4CvkZDGR/k4j9S8+vlTJXPI4hyVnyb54=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  __darwinAllowLocalNetworking = true;
  build-system = [ hatchling ];
  enabledTestPaths = [ "iamdata/tests/*.py" ];
  pyproject = true;
  pythonImportsCheck = [ "iamdata" ];

  meta = {
    description = "Module for utilizing AWS IAM data for Services, Actions, Resources, and Condition Keys";
    homepage = "https://github.com/cloud-copilot/iam-data-python";
    changelog = "https://github.com/cloud-copilot/iam-data-python/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
