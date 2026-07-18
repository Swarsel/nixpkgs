{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  html5lib,
  jsonschema,
  pytest-cov-stub,
  pytest-mock,
  pytest-recording,
  pytestCheckHook,
  python-dateutil,
  requests-mock,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pystac";
  version = "1.14.3";

  src = fetchFromGitHub {
    owner = "stac-utils";
    repo = "pystac";
    tag = "v${version}";
    hash = "sha256-O17KG8DRr7KpFpZYsl7zHBKDs5Ad0vigaThBnNP17rs=";
  };

  propagatedBuildInputs = [ python-dateutil ];

  nativeCheckInputs = [
    html5lib
    jsonschema
    pytestCheckHook
    pytest-cov-stub
    pytest-mock
    pytest-recording
    requests-mock
  ];

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "pystac" ];

  meta = {
    description = "Python library for working with any SpatioTemporal Asset Catalog (STAC)";
    homepage = "https://github.com/stac-utils/pystac";
    license = lib.licenses.asl20;
    teams = [ lib.teams.geospatial ];
  };
}
