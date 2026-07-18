{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pysigma,
  pysigma-pipeline-sysmon,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "pysigma-backend-qradar";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "nNipsx-Sec";
    repo = "pySigma-backend-qradar";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VymaxX+iqrRlf+WEt4xqEvNt5kg8xI5O/MoYahayu0o=";
  };

  nativeCheckInputs = [
    pysigma-pipeline-sysmon
    pytestCheckHook
  ];

  build-system = [ poetry-core ];
  dependencies = [ pysigma ];

  disabledTests = [
    # Output format unknown
    "test_qradar_extension_output"
  ];

  pyproject = true;
  pythonImportsCheck = [ "sigma.backends.qradar" ];
  pythonRelaxDeps = [ "pysigma" ];

  meta = {
    description = "Library to support Qradar for pySigma";
    homepage = "https://github.com/nNipsx-Sec/pySigma-backend-qradar";
    changelog = "https://github.com/nNipsx-Sec/pySigma-backend-qradar/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [ fab ];
  };
})
