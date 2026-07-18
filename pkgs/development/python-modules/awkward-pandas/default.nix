{
  lib,
  # dependencies
  awkward,
  buildPythonPackage,
  fetchPypi,
  # build-system
  hatch-vcs,
  hatchling,
  pandas,
}:

buildPythonPackage rec {
  pname = "awkward-pandas";
  version = "2023.8.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-Vre3NSQVAkI6ya+0nbDdO7WQWlGlPN/kdunUMWqXX94=";
    pname = "awkward_pandas";
  };

  # There are no tests in the Pypi archive
  doCheck = false;

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [
    awkward
    pandas
  ];

  pyproject = true;

  pythonImportsCheck = [
    "awkward_pandas"
  ];

  meta = {
    description = "Awkward Array Pandas Extension";
    homepage = "https://pypi.org/project/awkward-pandas/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
