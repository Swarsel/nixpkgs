{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  geopandas,
  pooch,
  pyogrio,
  pytestCheckHook,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "geodatasets";
  version = "2026.5.1";

  src = fetchFromGitHub {
    owner = "geopandas";
    repo = "geodatasets";
    tag = version;
    hash = "sha256-wKe5hDK0J3e+9PyMvH1dJWpNMC8Ct4u5ysJoi7/xw4k=";
  };

  nativeCheckInputs = [
    geopandas
    pyogrio
    pytestCheckHook
  ];

  preCheck = ''
    export HOME=$TMPDIR
  '';

  build-system = [ setuptools-scm ];
  dependencies = [ pooch ];

  disabledTestMarks = [
    # disable tests which require network access
    "request"
  ];

  pyproject = true;
  pythonImportsCheck = [ "geodatasets" ];

  meta = {
    description = "Spatial data examples";
    homepage = "https://geodatasets.readthedocs.io/";
    license = lib.licenses.bsd3;
    teams = [ lib.teams.geospatial ];
  };
}
