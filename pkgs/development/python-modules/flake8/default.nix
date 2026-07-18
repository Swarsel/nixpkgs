{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  isPyPy,
  mccabe,
  pycodestyle,
  pyflakes,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "flake8";
  version = "7.3.0";

  src = fetchFromGitHub {
    owner = "PyCQA";
    repo = "flake8";
    tag = version;
    hash = "sha256-dZFIGyjqkd+MRz9NoOEcMuR9ZshFb/h+zO2OJZsQajc=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    mccabe
    pycodestyle
    pyflakes
  ];

  disabledTests = lib.optionals isPyPy [
    # tests fail due to slightly different error position
    "test_tokenization_error_is_a_syntax_error"
    "test_tokenization_error_but_not_syntax_error"
  ];

  pyproject = true;

  meta = {
    description = "Modular source code checker: pep8, pyflakes and co";
    homepage = "https://github.com/PyCQA/flake8";
    changelog = "https://github.com/PyCQA/flake8/blob/${src.tag}/docs/source/release-notes/${version}.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
    mainProgram = "flake8";
  };
}
