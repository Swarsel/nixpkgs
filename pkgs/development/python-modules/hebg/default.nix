{
  lib,
  stdenv,
  buildPythonPackage,
  fetchPypi,
  matplotlib,
  # Runtime dependencies
  networkx,
  numpy,
  pytest-check,
  pytest-mock,
  pytestCheckHook,
  scipy,
  # Build, dev and test dependencies
  setuptools-scm,
  tqdm,
}:

buildPythonPackage rec {
  pname = "hebg";
  version = "0.2.4";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-11bz+FbnaEVLiXT1eujMw8lvABlzVOeROOsdVgsyfjQ=";
  };

  env = lib.optionalAttrs stdenv.hostPlatform.isDarwin { MPLBACKEND = "Agg"; };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-check
    pytest-mock
  ];

  build-system = [ setuptools-scm ];

  dependencies = [
    networkx
    matplotlib
    numpy
    tqdm
    scipy
  ];

  disabledTests = [
    # exec()'d class no longer leaks into locals() under PEP 667
    "test_exec_codegen"
  ];

  pyproject = true;
  pythonImportsCheck = [ "hebg" ];

  meta = {
    description = "Hierachical Explainable Behaviors using Graphs";
    homepage = "https://github.com/IRLL/HEB_graphs";
    changelog = "https://github.com/IRLL/HEB_graphs/releases/tag/${version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ automathis ];
  };
}
