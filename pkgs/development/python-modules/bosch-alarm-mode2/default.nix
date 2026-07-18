{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatch-vcs,
  hatchling,
}:

buildPythonPackage rec {
  pname = "bosch-alarm-mode2";
  version = "0.4.10";

  src = fetchFromGitHub {
    owner = "mag1024";
    repo = "bosch-alarm-mode2";
    tag = "v${version}";
    hash = "sha256-XpLMPFi3e6iTtKGfVXN4VbnPyNLVjSFrodyFK+zelF4=";
  };

  # upstream has no tests
  doCheck = false;

  build-system = [
    hatch-vcs
    hatchling
  ];

  pyproject = true;
  pythonImportsCheck = [ "bosch_alarm_mode2" ];

  meta = {
    description = "Async Python library for interacting with Bosch Alarm Panels supporting the 'Mode 2' API";
    homepage = "https://github.com/mag1024/bosch-alarm-mode2";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
