{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  geopandas,
  inequality,
  libpysal,
  mapclassify,
  networkx,
  packaging,
  pandas,
  pytestCheckHook,
  setuptools-scm,
  shapely,
  tqdm,
}:

buildPythonPackage rec {
  pname = "momepy";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "pysal";
    repo = "momepy";
    tag = "v${version}";
    hash = "sha256-Og7W+35k9HIIEFGcDmsxggb1BT5cwnaMIi3HO3VRAX0=";
  };

  patches = [
    # see https://github.com/pysal/momepy/pull/733
    ./fix_test_elements.patch
  ];

  propagatedBuildInputs = [
    geopandas
    inequality
    libpysal
    mapclassify
    networkx
    packaging
    pandas
    shapely
    tqdm
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools-scm ];

  disabledTestPaths = [
    # this tests depends on neatnet, not packaged in nixpkgs
    # it's probably not worthy to package it just for this test
    "momepy/tests/test_continuity.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "momepy" ];

  meta = {
    description = "Urban Morphology Measuring Toolkit";
    homepage = "https://github.com/pysal/momepy";
    license = lib.licenses.bsd3;
    teams = [ lib.teams.geospatial ];
  };
}
