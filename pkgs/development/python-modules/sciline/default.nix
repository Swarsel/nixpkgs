{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  cyclebane,
  dask,
  graphviz,
  jsonschema,
  numpy,
  pandas,
  pydantic,
  pytest-randomly,
  # tests
  pytestCheckHook,
  rich,
  # build-system
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "sciline";
  version = "25.11.1";

  src = fetchFromGitHub {
    owner = "scipp";
    repo = "sciline";
    tag = finalAttrs.version;
    hash = "sha256-BTdvPAeI7SWV8gNfXVC63YKghZOfJ9eFousOqycpTAw=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-randomly
    dask
    graphviz
    jsonschema
    numpy
    pandas
    pydantic
    rich
  ];

  __structuredAttrs = true;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    cyclebane
  ];

  pyproject = true;

  pythonImportsCheck = [
    "sciline"
  ];

  meta = {
    description = "Build scientific pipelines for your data";
    homepage = "https://scipp.github.io/sciline/";
    changelog = "https://github.com/scipp/sciline/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
})
