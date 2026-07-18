{
  lib,
  # dependencies
  bidsschematools,
  buildPythonPackage,
  fetchPypi,
  # build-system
  setuptools,
  versioneer,
}:

buildPythonPackage rec {
  pname = "bids-validator";
  version = "1.14.7.post0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-5gBaUAt1+KlhWT+2fUYIUQfa2xFvWaXDtSSqBpeUW2Y=";
    pname = "bids_validator";
  };

  build-system = [
    setuptools
    versioneer
  ];

  dependencies = [
    bidsschematools
  ];

  pyproject = true;
  pythonImportsCheck = [ "bids_validator" ];

  meta = {
    description = "Validator for the Brain Imaging Data Structure";
    homepage = "https://github.com/bids-standard/bids-validator";
    changelog = "https://github.com/bids-standard/bids-validator/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ wegank ];
  };
}
