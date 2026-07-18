{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pi1wire";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "ushiboy";
    repo = "pi1wire";
    tag = "v${version}";
    hash = "sha256-l/5w71QsAW4BvILOaLdUVvQ8xxUm1ZTzUESRFzUgtic=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  disabledTests = [
    "test_find_all_sensors" # flaky
  ];

  format = "setuptools";
  pythonImportsCheck = [ "pi1wire" ];

  meta = {
    description = "1Wire Sensor Library for Raspberry PI";
    homepage = "https://github.com/ushiboy/pi1wire";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
