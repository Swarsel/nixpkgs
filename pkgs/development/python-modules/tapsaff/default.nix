{
  lib,
  buildPythonPackage,
  fetchPypi,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "tapsaff";
  version = "0.2.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Q3VLbPsgXAYvZsjcW1m3lus2SFMjNJ8AmkcNK0THB6I=";
  };

  # Package does not have tests
  doCheck = false;

  build-system = [
    setuptools
  ];

  dependencies = [
    requests
  ];

  pyproject = true;

  pythonImportsCheck = [
    "tapsaff"
  ];

  meta = {
    description = "Provides an API for requesting information from taps-aff.co.uk";
    homepage = "https://github.com/bazwilliams/python-taps-aff";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
