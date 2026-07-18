{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "checkpoint-schedules";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "firedrakeproject";
    repo = "checkpoint_schedules";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3bn/KxxtRLRtOHFeULQdnndonpuhuYLL8/y/zoAurzY=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    numpy
  ];

  pyproject = true;

  pythonImportsCheck = [
    "checkpoint_schedules"
  ];

  meta = {
    description = "Schedules for incremental checkpointing of adjoint simulations";
    homepage = "https://www.firedrakeproject.org/checkpoint_schedules";
    changelog = "https://github.com/firedrakeproject/checkpoint_schedules/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ qbisi ];
    downloadPage = "https://github.com/firedrakeproject/checkpoint_schedules";
  };
})
