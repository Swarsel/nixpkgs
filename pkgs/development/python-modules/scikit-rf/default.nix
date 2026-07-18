{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  ipykernel,
  ipython,
  ipywidgets,
  jupyter-client,
  matplotlib,
  nbsphinx,
  nbval,
  networkx,
  numpy,
  openpyxl,
  pandas,
  pytest-cov-stub,
  pytest-mock,
  pytestCheckHook,
  pyvisa,
  scipy,
  setuptools,
  sphinx,
  sphinx-rtd-theme,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "scikit-rf";
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "scikit-rf";
    repo = "scikit-rf";
    tag = "v${version}";
    hash = "sha256-iOKTQOOJTsj6YIQaJVWFcp9HdUEj43aytpo7VzItxr8=";
  };

  env = lib.optionalAttrs stdenv.hostPlatform.isDarwin { MPLBACKEND = "Agg"; };

  nativeCheckInputs = [
    pytest-mock
    matplotlib
    pyvisa
    openpyxl
    networkx
    pytestCheckHook
    pytest-cov-stub
    writableTmpDirAsHomeHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    numpy
    scipy
    pandas
  ];

  disabledTests = [
    # numpy.exceptions.VisibleDeprecationWarning: dtype(): align should be
    #  passed as Python or NumPy boolean but got `align=0`
    "test_constructor_from_pathlib"
    "test_constructor_from_pickle"
    "test_constructor_from_touchstone_special_encoding"
  ];

  optional-dependencies = {
    docs = [
      ipython
      ipykernel
      ipywidgets
      jupyter-client
      sphinx-rtd-theme
      sphinx
      nbsphinx
      openpyxl
      nbval
    ];

    netw = [ networkx ];
    plot = [ matplotlib ];
    visa = [ pyvisa ];
    xlsx = [ openpyxl ];
  };

  pyproject = true;
  pytestFlags = [ "-Wignore::pytest.PytestUnraisableExceptionWarning" ];
  pythonImportsCheck = [ "skrf" ];
  pythonRemoveDeps = [ "pre-commit" ];

  meta = {
    description = "Python library for RF/Microwave engineering";
    homepage = "https://scikit-rf.org/";
    changelog = "https://github.com/scikit-rf/scikit-rf/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ lugarun ];
  };
}
