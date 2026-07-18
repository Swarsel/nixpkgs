{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  flit-core,
  pydantic,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  pytz,
  requests,
  responses,
}:

buildPythonPackage rec {
  pname = "fhir-py";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "beda-software";
    repo = "fhir-py";
    tag = "v${version}";
    hash = "sha256-C6ttVEYsnOzA4PFtq0wHfXrGSvpXOj0/oTuVDtx19qc=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
    pytest-cov-stub
    pydantic
    responses
  ];

  build-system = [ flit-core ];

  dependencies = [
    aiohttp
    pytz
    requests
  ];

  # sync/async test cases require docker-compose to set up services, so disable:
  disabledTestPaths = [ "tests/test_lib_sync.py" ];
  disabledTests = [ "TestLibAsyncCase" ];
  pyproject = true;
  pythonImportsCheck = [ "fhirpy" ];

  meta = {
    description = "Async/sync API for FHIR resources";
    homepage = "https://github.com/beda-software/fhir-py";
    changelog = "https://github.com/beda-software/fhir-py/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
}
