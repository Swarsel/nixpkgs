{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  hatchling,
  # tests
  matplotlib,
  # dependencies
  numpy,
  packaging,
  pandas,
  prettytable,
  pytest-cov-stub,
  pytestCheckHook,
  pyyaml,
  rich,
  scikit-learn,
  streamlit,
  tabulate,
}:

buildPythonPackage (finalAttrs: {
  pname = "skops";
  version = "0.14";

  src = fetchFromGitHub {
    owner = "skops-dev";
    repo = "skops";
    tag = "v${finalAttrs.version}";
    hash = "sha256-AyrsXomc3vpfdqsBL51UmGXsjPsAJ+dx3uf3T8nPk/Y=";
  };

  nativeCheckInputs = [
    matplotlib
    pandas
    pytest-cov-stub
    pytestCheckHook
    pyyaml
    streamlit
  ];

  __structuredAttrs = true;
  build-system = [ hatchling ];

  dependencies = [
    numpy
    packaging
    prettytable
    scikit-learn
    tabulate
  ];

  disabledTests = [
    # fairlearn is not available in nixpkgs
    "TestAddFairlearnMetricFrame"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # Fail in the sandbox with:
    #   UNEXPECTED EXCEPTION: RuntimeError('*** -[__NSPlaceholderArray initWithObjects:count:]:
    #   attempt to insert nil object from objects[1]')
    "skops.card._model_card.Card"
    "test_add_plot"
    "test_add_plot_to_existing_section"
    "test_add_plot_with_alt_text"
    "test_add_plot_with_description"
    "test_copy_plots"
    "test_duplicate_permutation_importances"
    "test_duplicate_permutation_importances_overwrite"
    "test_multiple_permutation_importances"
    "test_permutation_importances"
    "test_permutation_importances_with_description"
  ];

  enabledTestPaths = [ "skops" ];

  optional-dependencies = {
    rich = [ rich ];
  };

  pyproject = true;
  pythonImportsCheck = [ "skops" ];

  meta = {
    description = "Library for saving/loading, sharing, and deploying scikit-learn based models";
    homepage = "https://skops.readthedocs.io/en/stable";
    changelog = "https://github.com/skops-dev/skops/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.bcdarwin ];
    mainProgram = "skops";
  };
})
