{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  librouteros,
  napalm,
  pytestCheckHook,
  pythonAtLeast,
  setuptools,
}:
buildPythonPackage rec {
  pname = "napalm-ros";
  version = "1.2.6";

  src = fetchFromGitHub {
    owner = "napalm-automation-community";
    repo = "napalm-ros";
    tag = version;
    hash = "sha256-Fv11Blx44vZZ8NuhQQIFpDr+dH2gDJtQP7b0kAk3U/s=";
  };

  nativeCheckInputs = [
    napalm
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ librouteros ];

  disabledTests = [
    # AssertionError: Some methods vary.
    "test_method_signatures"
  ];

  pyproject = true;
  pythonImportsCheck = [ "napalm_ros" ];

  meta = {
    description = "MikroTik RouterOS NAPALM driver";
    homepage = "https://github.com/napalm-automation-community/napalm-ros";
    changelog = "https://github.com/napalm-automation-community/napalm-ros/releases/tag/${src.tag}";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ felbinger ];
    platforms = lib.platforms.linux;
  };
}
