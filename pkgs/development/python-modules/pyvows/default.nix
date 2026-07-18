{
  lib,
  buildPythonPackage,
  fetchPypi,
  gevent,
  preggy,
  python,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyvows";
  version = "3.0.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-2+4umWLNkbFlCpfFwX0FA2N0zOZhst/YM4ozBfXoaMI=";
    pname = "pyVows";
  };

  checkPhase = ''
    ${python.interpreter} pyvows/cli.py tests/
  '';

  build-system = [ setuptools ];

  dependencies = [
    gevent
    preggy
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyvows" ];

  meta = {
    description = "BDD test engine based on Vows.js";
    homepage = "https://github.com/heynemann/pyvows";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ joachimschmidt557 ];
  };
}
