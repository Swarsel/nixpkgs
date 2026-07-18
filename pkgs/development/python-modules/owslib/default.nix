{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  lxml,
  pytest-cov-stub,
  pytest-httpserver,
  pytestCheckHook,
  python-dateutil,
  pyyaml,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "owslib";
  version = "0.36.0";

  src = fetchFromGitHub {
    owner = "geopython";
    repo = "OWSLib";
    tag = version;
    hash = "sha256-Of/CSLcNnpTYHRm4toQK4/HXTWNcuEMkW6obWpg96Tc=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools<69" "setuptools"
  '';

  nativeCheckInputs = [
    pytest-cov-stub
    pytest-httpserver
    pytestCheckHook
  ];

  preCheck = ''
    # _pytest.pathlib.ImportPathMismatchError: ('owslib.swe.sensor.sml', '/build/source/build/...
    export PY_IGNORE_IMPORTMISMATCH=1
  '';

  build-system = [ setuptools ];

  dependencies = [
    lxml
    python-dateutil
    pyyaml
    requests
  ];

  disabledTestMarks = [
    # Disable tests which require network access
    "online"
  ];

  disabledTestPaths = [
    # Tests requires network access
    "tests/test_ogcapi_connectedsystems_osh.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "owslib" ];

  meta = {
    description = "Client for Open Geospatial Consortium web service interface standards";
    homepage = "https://www.osgeo.org/projects/owslib/";
    changelog = "https://github.com/geopython/OWSLib/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    teams = [ lib.teams.geospatial ];
  };
}
