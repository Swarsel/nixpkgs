{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  requests,
  requests-mock,
  setuptools,
}:

buildPythonPackage rec {
  pname = "wirelesstagpy";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "sergeymaysak";
    repo = "wirelesstagpy";
    tag = version;
    hash = "sha256-xmcXBlApteGAQwfNx6fmFkP7enRy3Iy19+6mAjc7LWA=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    requests-mock
  ];

  build-system = [ setuptools ];
  dependencies = [ requests ];

  disabledTestPaths = [
    # Requires tl.testing dependency
    "test/test_cloud_push.py"
  ];

  enabledTests = [ "test" ];
  pyproject = true;

  pythonImportsCheck = [
    "wirelesstagpy"
    "wirelesstagpy.constants"
    "wirelesstagpy.notificationconfig"
    "wirelesstagpy.sensortag"
    "wirelesstagpy.binaryevent"
  ];

  meta = {
    description = "Simple python wrapper over wirelesstags REST API";
    homepage = "https://github.com/sergeymaysak/wirelesstagpy";
    changelog = "https://github.com/sergeymaysak/wirelesstagpy/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
