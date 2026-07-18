{
  lib,
  buildPythonPackage,
  fetchPypi,
  pexpect,
  poetry-core,
  # Python deps
  requests,
}:

buildPythonPackage rec {
  pname = "cardano-tools";
  version = "2.1.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-RFyKXHafV+XgRJSsTjASCCw9DxvZqertf4NNN616Bp4=";
    pname = "cardano_tools";
  };

  build-system = [ poetry-core ];

  dependencies = [
    requests
    pexpect
  ];

  pyproject = true;
  pythonImportsCheck = [ "cardano_tools" ];

  meta = {
    description = "Python module for interfacing with the Cardano blockchain";
    homepage = "https://gitlab.com/viperscience/cardano-tools";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ aciceri ];
  };
}
