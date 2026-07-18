{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pydantic,
  sensorpush-api,
  setuptools,
}:

buildPythonPackage rec {
  pname = "sensorpush-ha";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "sstallion";
    repo = "sensorpush-ha";
    tag = "v${version}";
    hash = "sha256-Gs6WprGscr9fiu78S0OY6624LA87Of7OWkNNnaWIxJk=";
  };

  # upstream has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    pydantic
    sensorpush-api
  ];

  pyproject = true;
  pythonImportsCheck = [ "sensorpush_ha" ];

  meta = {
    description = "SensorPush Cloud Home Assistant Library";
    homepage = "https://github.com/sstallion/sensorpush-ha";
    changelog = "https://github.com/sstallion/sensorpush-ha/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
