{
  lib,
  buildPythonPackage,
  click,
  fetchPypi,
  inflection,
  mock,
  pydantic,
  pytest,
  pytest-cov-stub,
  requests,
  requests-mock,
  setuptools,
  tox,
  urllib3,
}:

buildPythonPackage rec {
  pname = "pyairtable";
  version = "3.4.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-umABkxSJSMEACenkRJSRkJp9qLqUvIv6r4ZGsO6MA8o=";
  };

  nativeCheckInputs = [
    pytest
    pytest-cov-stub
    mock
    requests-mock
    tox
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    setuptools
    inflection
    pydantic
    requests
    urllib3
    click
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyairtable" ];

  meta = {
    description = "Python API Client for Airtable";
    homepage = "https://pyairtable.readthedocs.io/";
    changelog = "https://pyairtable.readthedocs.io/en/${version}/changelog.html";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ stupidcomputer ];
    mainProgram = "pyairtable";
  };
}
