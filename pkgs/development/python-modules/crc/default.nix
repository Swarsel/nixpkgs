{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "crc";
  version = "7.1.0";

  src = fetchFromGitHub {
    owner = "Nicoretti";
    repo = "crc";
    tag = version;
    hash = "sha256-Oa2VSzNT+8O/rWZurIr7RnP8m3xAEVOQLs+ObT4xIa0=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];
  disabledTestPaths = [ "test/bench" ];
  pyproject = true;
  pythonImportsCheck = [ "crc" ];

  meta = {
    description = "Python module for calculating and verifying predefined & custom CRC's";
    homepage = "https://nicoretti.github.io/crc/";
    changelog = "https://github.com/Nicoretti/crc/releases/tag/${version}";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ jleightcap ];
    mainProgram = "crc";
  };
}
