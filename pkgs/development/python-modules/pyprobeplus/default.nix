{
  lib,
  fetchFromGitHub,
  bleak,
  bleak-retry-connector,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyprobeplus";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "pantherale0";
    repo = "pyprobeplus";
    tag = version;
    hash = "sha256-CJbQs0xZHdXNPX71G1KrrHHV58gXaQsUHGcX9P8E+iY=";
  };

  # upstream has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    bleak
    bleak-retry-connector
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyprobeplus" ];

  meta = {
    description = "Generic library to interact with a Probe Plus BLE device";
    homepage = "https://github.com/pantherale0/pyprobeplus";
    changelog = "https://github.com/pantherale0/pyprobeplus/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
