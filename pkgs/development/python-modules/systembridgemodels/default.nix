{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  syrupy,
}:

buildPythonPackage rec {
  pname = "systembridgemodels";
  version = "5.1.1";

  src = fetchFromGitHub {
    owner = "timmo001";
    repo = "system-bridge-models";
    tag = version;
    hash = "sha256-Yh16la+3zk+igdMyHov4rf2M1yAT3JYYe/0IYu/SmVY=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail ".dev0" ""
  '';

  nativeCheckInputs = [
    pytestCheckHook
    syrupy
  ];

  build-system = [ setuptools ];

  disabledTestPaths = [
    # https://github.com/timmo001/system-bridge-models/commit/9523179e73b6a13b9987fa861d77bfeeb88203a7
    "tests/test_update.py"
    "tests/test_version.py"
  ];

  disabledTests = [
    "test_system"
    "test_update"
  ];

  pyproject = true;
  pytestFlags = [ "--snapshot-warn-unused" ];
  pythonImportsCheck = [ "systembridgemodels" ];

  meta = {
    description = "This is the models package used by the System Bridge project";
    homepage = "https://github.com/timmo001/system-bridge-models";
    changelog = "https://github.com/timmo001/system-bridge-models/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
