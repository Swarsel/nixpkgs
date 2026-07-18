{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cons,
  multipledispatch,
  py,
  pytest-html,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "etuples";
  version = "0.3.10";

  src = fetchFromGitHub {
    owner = "pythological";
    repo = "etuples";
    tag = "v${version}";
    hash = "sha256-h5MLj1z3qZiUXcNIDtUIbV5zeyTzxerbSezFD5Q27n0=";
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

  dependencies = [
    cons
    multipledispatch
  ];

  pyproject = true;

  pytestFlags = [
    "--html=testing-report.html"
    "--self-contained-html"
  ];

  pythonImportsCheck = [ "etuples" ];

  meta = {
    description = "Python S-expression emulation using tuple-like objects";
    homepage = "https://github.com/pythological/etuples";
    changelog = "https://github.com/pythological/etuples/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ Etjean ];
  };
}
