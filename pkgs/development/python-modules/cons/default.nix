{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  logical-unification,
  py,
  pytest-html,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "cons";
  version = "0.4.7";

  src = fetchFromGitHub {
    owner = "pythological";
    repo = "python-cons";
    tag = "v${version}";
    hash = "sha256-BS7lThnv+dxtztvw2aRhQa8yx2cRfrZLiXjcwvZ8QR0=";
  };

  nativeCheckInputs = [
    py
    pytestCheckHook
    pytest-html
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [ logical-unification ];
  pyproject = true;

  pytestFlags = [
    "--html=testing-report.html"
    "--self-contained-html"
  ];

  pythonImportsCheck = [ "cons" ];

  meta = {
    description = "Implementation of Lisp/Scheme-like cons in Python";
    homepage = "https://github.com/pythological/python-cons";
    changelog = "https://github.com/pythological/python-cons/releases/tag/${src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ Etjean ];
  };
}
