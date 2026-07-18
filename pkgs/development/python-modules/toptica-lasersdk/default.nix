{
  lib,
  buildPythonPackage,
  fetchPypi,
  # dependencies
  ifaddr,
  pyserial,
  # build-system
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "toptica-lasersdk";
  version = "3.3.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-VzgQCqfZP9JoFmotG0jPJpHMxLY+unNZqzxQGhtlYC4=";
    pname = "toptica_lasersdk";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    ifaddr
    pyserial
  ];

  pyproject = true;

  pythonImportsCheck = [
    "toptica.lasersdk.dlcpro.v2_2_0"
  ];

  meta = {
    description = "TOPTICA Python Laser SDK";
    homepage = "https://toptica.github.io/python-lasersdk/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
})
