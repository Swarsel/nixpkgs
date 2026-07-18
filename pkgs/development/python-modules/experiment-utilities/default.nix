{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  cloudpickle,
  dill,
  fasteners,
  ipynbname,
  ipywidgets,
  notebook,
  numpy,
  odfpy,
  plotly,
  # tests
  pytestCheckHook,
  pyyaml,
  qgrid,
  scipy,
  six,
  tabulate,
  tensorboard,
  torch,
}:

buildPythonPackage rec {
  pname = "experiment-utilities";
  version = "0.3.9";

  src = fetchFromGitHub {
    owner = "ChrisReinke";
    repo = "exputils";
    tag = "v${version}";
    hash = "sha256-LQ1RjDcOL1SroNzWSfSS2OUSqsGgWOly7bLcbZ7e8LY=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    torch
  ];

  dependencies = [
    cloudpickle
    dill
    fasteners
    ipynbname
    ipywidgets
    notebook
    numpy
    odfpy
    plotly
    pyyaml
    qgrid
    scipy
    six
    tabulate
    tensorboard
  ];

  disabledTests = [
    "test_experimentstarter"
    # https://github.com/ChrisReinke/exputils/issues/4
    "test_different_datatypes"
  ];

  pyproject = true;
  pythonImportsCheck = [ "exputils" ];

  pythonRelaxDeps = [
    "notebook"
    "ipywidgets"
  ];

  pythonRemoveDeps = [
    # Not available anymore in nixpkgs
    "jupyter_contrib_nbextensions"
  ];

  meta = {
    description = "Various tools to run scientific computer experiments";
    homepage = "https://gitlab.inria.fr/creinke/exputils";
    changelog = "https://github.com/ChrisReinke/exputils/releases/tag/v${version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
