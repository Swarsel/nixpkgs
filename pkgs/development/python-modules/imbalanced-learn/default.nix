{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  joblib,
  keras,
  numpy,
  pandas,
  pytestCheckHook,
  python,
  scikit-learn,
  scipy,
  setuptools,
  setuptools-scm,
  sklearn-compat,
  tensorflow,
  threadpoolctl,
}:

buildPythonPackage rec {
  pname = "imbalanced-learn";
  version = "0.14.2";

  src = fetchFromGitHub {
    owner = "scikit-learn-contrib";
    repo = "imbalanced-learn";
    tag = version;
    hash = "sha256-uWln6+r9QsGnH4I4JQm2/y80zTQkAflVPlIN9KQNzy0=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pandas
  ];

  preCheck = ''
    export HOME=$TMPDIR
    # The GitHub source contains too many files picked up by pytest like
    # examples and documentation files which can't pass.
    cd $out/${python.sitePackages}
  '';

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    joblib
    numpy
    scikit-learn
    scipy
    threadpoolctl
    sklearn-compat
  ];

  disabledTestPaths = [
    # require tensorflow and keras, but we don't want to
    # add them to nativeCheckInputs just for this tests
    "imblearn/keras"
    "imblearn/tensorflow"
    # even with precheck directory change, pytest still tries to test docstrings
    "imblearn/tests/test_docstring_parameters.py"
    # Skip dependencies test - pythonImportsCheck already does this
    "imblearn/utils/tests/test_min_dependencies.py"
  ];

  optional-dependencies = {
    optional = [
      keras
      pandas
      tensorflow
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "imblearn" ];

  meta = {
    description = "Library offering a number of re-sampling techniques commonly used in datasets showing strong between-class imbalance";
    homepage = "https://github.com/scikit-learn-contrib/imbalanced-learn";
    changelog = "https://github.com/scikit-learn-contrib/imbalanced-learn/releases/tag/${src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      rmcgibbo
      jadewilk
    ];
  };
}
