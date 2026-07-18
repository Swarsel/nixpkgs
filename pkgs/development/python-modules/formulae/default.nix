{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  numpy,
  packaging,
  pandas,
  # tests
  pytestCheckHook,
  scipy,
  # build-system
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "formulae";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "bambinos";
    repo = "formulae";
    tag = finalAttrs.version;
    hash = "sha256-Q+oHt9euUBQs/D5TlJeeUN76HwQkmGHC1cTzmAQx+2M=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    numpy
    packaging
    pandas
    scipy
  ];

  disabledTests = [
    # use assertions of form `assert pytest.approx(...)`, which is now disallowed:
    "test_basic"
    "test_degree"
    # AssertionError
    "test_evalenv_equality"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "formulae"
    "formulae.matrices"
  ];

  meta = {
    description = "Formulas for mixed-effects models in Python";
    homepage = "https://bambinos.github.io/formulae";
    changelog = "https://github.com/bambinos/formulae/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
})
