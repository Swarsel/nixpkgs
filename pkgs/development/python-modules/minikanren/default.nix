{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  cons,
  etuples,
  logical-unification,
  multipledispatch,
  # tests
  py,
  pytest-html,
  pytestCheckHook,
  # build-system
  setuptools,
  setuptools-scm,
  toolz,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "minikanren";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "pythological";
    repo = "kanren";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lCQ0mKT99zK5A74uoo/9bP+eFdm3MC43Fh8+P2krXrs=";
  };

  nativeCheckInputs = [
    py
    pytest-html
    pytestCheckHook
  ];

  __structuredAttrs = true;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    cons
    etuples
    logical-unification
    multipledispatch
    toolz
    typing-extensions
  ];

  pyproject = true;

  pytestFlags = [
    "--html=testing-report.html"
    "--self-contained-html"
  ];

  pythonImportsCheck = [ "kanren" ];

  meta = {
    description = "Relational programming in Python";
    homepage = "https://github.com/pythological/kanren";
    changelog = "https://github.com/pythological/kanren/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ Etjean ];
  };
})
