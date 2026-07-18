{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "dropmqttapi";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "ChandlerSystems";
    repo = "dropmqttapi";
    tag = "v${version}";
    hash = "sha256-njReF9Mu5E9o5WcbK60CCBWaIhZ3tpQHHlY/iEyyHGg=";
  };

  # Module has no test
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "dropmqttapi" ];

  meta = {
    description = "Python MQTT API for DROP water management products";
    homepage = "https://github.com/ChandlerSystems/dropmqttapi";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
