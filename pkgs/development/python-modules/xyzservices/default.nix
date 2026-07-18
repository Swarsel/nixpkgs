{
  lib,
  buildPythonPackage,
  fetchPypi,
  mercantile,
  pytestCheckHook,
  requests,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "xyzservices";
  version = "2026.3.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-0iaGal2On+8zcDTY2jeoKY8KHZ0UibQBjmlXnrMh/qQ=";
  };

  nativeBuildInputs = [
    setuptools
    setuptools-scm
  ];

  nativeCheckInputs = [
    mercantile
    pytestCheckHook
    requests
  ];

  disabledTestMarks = [
    # requires network connections
    "request"
  ];

  pyproject = true;
  pythonImportsCheck = [ "xyzservices.providers" ];

  meta = {
    description = "Source of XYZ tiles providers";
    homepage = "https://github.com/geopandas/xyzservices";
    changelog = "https://github.com/geopandas/xyzservices/releases/tag/${version}";
    license = lib.licenses.bsd3;
    teams = [ lib.teams.geospatial ];
  };
}
