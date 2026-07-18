{
  lib,
  fetchFromGitLab,
  buildPythonPackage,
  # nativeCheckInputs
  pytestCheckHook,
  # build-system
  setuptools,
  setuptools-scm,
  # dependencies
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "declinate";
  version = "0.0.6";

  src = fetchFromGitLab {
    owner = "ternaris";
    repo = "declinate";
    tag = "v${version}";
    hash = "sha256-JEO/GtbG/yQuj8vJJaWex9mGy6qpWOPHGlKrdG9vt28=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    typing-extensions
  ];

  pyproject = true;

  pythonImportsCheck = [
    "declinate"
  ];

  meta = {
    description = "Command line interface generator";
    homepage = "https://gitlab.com/ternaris/declinate";
    changelog = "https://gitlab.com/ternaris/declinate/-/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ nim65s ];
  };
}
