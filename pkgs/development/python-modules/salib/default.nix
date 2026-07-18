{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatch-vcs,
  hatchling,
  matplotlib,
  multiprocess,
  numpy,
  pandas,
  pathos,
  scipy,
}:
let
  finalAttrs = {
    pname = "salib";
    version = "1.5.2";

    src = fetchPypi {
      inherit (finalAttrs) pname version;
      hash = "sha256-qO7txOh88HD370ULds3s0SDR5cYCqcNYVex3d1kflJ8=";
    };

    # There are no tests in the pypi package
    doCheck = false;

    build-system = [
      hatchling
      hatch-vcs
    ];

    dependencies = [
      numpy
      scipy
      matplotlib
      pandas
      multiprocess
    ];

    optional-dependencies = {
      distributed = [ pathos ];
    };

    pyproject = true;

    pythonImportsCheck = [
      "SALib"
      "SALib.analyze"
      "SALib.plotting"
      "SALib.sample"
      "SALib.test_functions"
      "SALib.util"
    ];

    meta = {
      description = "Python implementations of commonly used sensitivity analysis methods, useful in systems modeling to calculate the effects of model inputs or exogenous factors on outputs of interest";
      homepage = "https://github.com/SALib/SALib";
      changelog = "https://github.com/SALib/SALib/releases";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ theobori ];
      mainProgram = "salib";
    };
  };
in
buildPythonPackage finalAttrs
