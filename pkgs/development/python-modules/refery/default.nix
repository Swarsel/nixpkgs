{
  lib,
  buildPythonPackage,
  colorama,
  fetchPypi,
  junit-xml,
  poetry-core,
  pyyaml,
}:

buildPythonPackage rec {
  pname = "refery";
  version = "2.1.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha512-ju0lqCSg0zcZNqRXDmFX6X1ugBocpmHMBWJApO6Tzhm/tLMQTKy2RpB4C8fkKCEWA2mYX4w1dLdHe68hZixwkQ==";
  };

  propagatedBuildInputs = [
    poetry-core
    pyyaml
    colorama
    junit-xml
  ];

  # No tests yet
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "refery" ];

  meta = {
    description = "Functional testing tool";
    homepage = "https://github.com/RostanTabet/refery";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ rostan-t ];
    mainProgram = "refery";
  };
}
