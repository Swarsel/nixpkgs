{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "lightwave";
  version = "0.24";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-l9hwdAKrpdXj/pkrgyiuhbPaGgT6tjfoOw/TBpR+k1I=";
  };

  # Requires physical hardware
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "lightwave" ];

  meta = {
    description = "Module for interacting with LightwaveRF hubs";
    homepage = "https://github.com/GeoffAtHome/lightwave";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
