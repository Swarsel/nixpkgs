{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  json-timeseries,
  numpy,
  pandas,
  pytestCheckHook,
  pyyaml,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage {
  pname = "openplantbook-sdk";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "slaxor505";
    repo = "openplantbook-sdk-py";
    rev = "097ccfbd5cee6a271c79c923f1761249eca4bda1";
    hash = "sha256-udzm8Efl3QX2jrvfzA/oCvk2kjQEFFOZCOFqKNzUUu8=";
  };

  patches = [
    # https://github.com/slaxor505/openplantbook-sdk-py/pull/2
    ./update-test.patch
  ];

  nativeBuildInputs = [
    numpy
    pandas
    pyyaml
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    aiohttp
    json-timeseries
  ];

  enabledTestPaths = [
    "tests/offline"
  ];

  pyproject = true;

  meta = {
    description = "SDK to integrate with Open Plantbook API";
    homepage = "https://github.com/slaxor505/openplantbook-sdk-py";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
  };
}
