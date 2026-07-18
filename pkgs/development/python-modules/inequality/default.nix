{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  libpysal,
  mapclassify,
  matplotlib,
  numpy,
  pytestCheckHook,
  scipy,
  seaborn,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "inequality";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "pysal";
    repo = "inequality";
    tag = "v${version}";
    hash = "sha256-GMl/hHwaHPozdLhV9/CPYIMY5lFYeo0X0SPDg4RT1zo=";
  };

  nativeCheckInputs = [
    mapclassify
    pytestCheckHook
    seaborn
  ];

  build-system = [ setuptools-scm ];

  dependencies = [
    libpysal
    matplotlib
    numpy
    scipy
  ];

  pyproject = true;
  pythonImportsCheck = [ "inequality" ];

  meta = {
    description = "Spatial inequality analysis";
    homepage = "https://github.com/pysal/inequality";
    license = lib.licenses.bsd3;
    teams = [ lib.teams.geospatial ];
  };
}
