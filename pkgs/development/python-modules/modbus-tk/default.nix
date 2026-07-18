{
  lib,
  buildPythonPackage,
  fetchPypi,
  pyserial,
  setuptools,
}:

buildPythonPackage rec {
  pname = "modbus-tk";
  version = "1.1.5";

  src = fetchPypi {
    inherit version;
    hash = "sha256-d6cqOtnV0yodIRC8BCFmgMpX11IpEuDycem/XxtwGzY=";
    pname = "modbus_tk";
  };

  # Source no tagged anymore and PyPI doesn't ship tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ pyserial ];
  pyproject = true;
  pythonImportsCheck = [ "modbus_tk" ];

  meta = {
    description = "Module for simple Modbus interactions";
    homepage = "https://github.com/ljean/modbus-tk";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ fab ];
  };
}
