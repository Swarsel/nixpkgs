{
  lib,
  buildPythonPackage,
  coverage,
  cryptography,
  fetchPypi,
  oslotest,
  pbr,
  python-dateutil,
  setuptools,
  stestr,
}:

buildPythonPackage rec {
  pname = "pyghmi";
  version = "1.6.18";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-lPDS72TvAALtI+D6YoT2rIvxj7J3FMSIw2t8SxZWslw=";
  };

  nativeCheckInputs = [
    coverage
    oslotest
    stestr
  ];

  checkPhase = ''
    runHook preCheck
    stestr run
    runHook postCheck
  '';

  build-system = [
    pbr
    setuptools
  ];

  dependencies = [
    cryptography
    python-dateutil
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyghmi" ];

  meta = {
    description = "Pure Python (mostly IPMI) server management library";
    homepage = "https://opendev.org/x/pyghmi/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ codgician ];
  };
}
