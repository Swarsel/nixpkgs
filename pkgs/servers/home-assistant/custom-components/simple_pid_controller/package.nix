{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  pytest-cov-stub,
  pytest-homeassistant-custom-component,
  pytestCheckHook,
  simple-pid,
  syrupy,
}:

buildHomeAssistantComponent (finalAttrs: {
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "bvweerd";
    repo = "simple_pid_controller";
    tag = "v${finalAttrs.version}";
    hash = "sha256-k/JT3sdGNYETWMat5hoiGv81N77Qz7Ks354vtk5PnvQ=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
    pytest-homeassistant-custom-component
    syrupy
  ];

  dependencies = [ simple-pid ];
  domain = "simple_pid_controller";
  owner = "bvweerd";

  meta = {
    description = "PID Controller integration for Home Assistant";
    homepage = "https://github.com/bvweerd/simple_pid_controller";
    changelog = "https://github.com/bvweerd/simple_pid_controller/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hexa ];
  };
})
