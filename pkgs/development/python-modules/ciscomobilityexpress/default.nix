{
  lib,
  buildPythonPackage,
  fetchPypi,
  python,
  requests,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "ciscomobilityexpress";
  version = "1.0.2";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-2HhyRVmOg3GoO6pNsd+UnYqULEPxNFT6Ju47CcPMr8A=";
  };

  # tests directory is set up, but has no tests
  checkPhase = ''
    ${python.interpreter} -m unittest
  '';

  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "ciscomobilityexpress" ];

  meta = {
    description = "Module to interact with Cisco Mobility Express APIs to fetch connected devices";
    homepage = "https://github.com/fbradyirl/ciscomobilityexpress";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ uvnikita ];
  };
})
