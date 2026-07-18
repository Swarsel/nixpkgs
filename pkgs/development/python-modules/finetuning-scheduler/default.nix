{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  pytestCheckHook,
  pythonAtLeast,
  # dependencies
  pytorch-lightning,
  # build-system
  setuptools,
  torch,
}:

buildPythonPackage (finalAttrs: {
  pname = "finetuning-scheduler";
  version = "2.10.0.post0";

  src = fetchFromGitHub {
    owner = "speediedan";
    repo = "finetuning-scheduler";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OeIpbxEjhvUzToy1jH9JcontSMfeozFjisTJCa0f4P0=";
  };

  # needed while lightning is installed as package `pytorch-lightning` rather than`lightning`:
  env.PACKAGE_NAME = "pytorch";
  nativeCheckInputs = [ pytestCheckHook ];
  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    pytorch-lightning
    torch
  ];

  disabledTests = [
    # AssertionError: assert 'lightning @ git+' in 'lightning>=2.5.0,<2.5.6'
    "test_get_lightning_requirement"
  ]
  ++ lib.optionals (pythonAtLeast "3.14") [
    # RuntimeError: torch.compile is not supported on Python 3.14+
    "test_fts_dynamo_enforce_p0"
    "test_fts_dynamo_resume"
  ]
  ++ lib.optionals (stdenv.hostPlatform.isAarch64 && stdenv.hostPlatform.isLinux) [
    # slightly exceeds numerical tolerance on aarch64-linux:
    "test_fts_frozen_bn_track_running_stats"
  ];

  enabledTestPaths = [ "tests" ];
  pyproject = true;
  pythonImportsCheck = [ "finetuning_scheduler" ];

  pythonRelaxDeps = [
    "pytorch-lightning"
  ];

  meta = {
    description = "PyTorch Lightning extension for foundation model experimentation with flexible fine-tuning schedules";
    homepage = "https://finetuning-scheduler.readthedocs.io";
    changelog = "https://github.com/speediedan/finetuning-scheduler/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
})
