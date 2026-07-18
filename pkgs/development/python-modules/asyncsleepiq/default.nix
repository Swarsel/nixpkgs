{
  lib,
  aiohttp,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "asyncsleepiq";
  version = "1.7.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-gOg1cxd2OsDRg5jtc6MfEMsK9T0Croo8K1jzsvbAbdY=";
  };

  nativeBuildInputs = [ setuptools ];
  propagatedBuildInputs = [ aiohttp ];
  # upstream has no tests
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "asyncsleepiq" ];

  meta = {
    description = "Async interface to SleepIQ API";
    homepage = "https://github.com/kbickar/asyncsleepiq";
    changelog = "https://github.com/kbickar/asyncsleepiq/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
