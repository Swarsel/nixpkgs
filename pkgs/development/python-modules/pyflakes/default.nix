{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  isPyPy,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyflakes";
  version = "3.4.0";

  src = fetchFromGitHub {
    owner = "PyCQA";
    repo = "pyflakes";
    tag = version;
    hash = "sha256-4UEJjn9Eey1vHeaG468x/nMlbfGu3ohZX1R7RR2R5ik=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  disabledTests = lib.optionals isPyPy [
    # https://github.com/PyCQA/pyflakes/issues/779
    "test_eofSyntaxError"
    "test_misencodedFileUTF16"
    "test_misencodedFileUTF8"
    "test_multilineSyntaxError"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyflakes" ];

  meta = {
    description = "Simple program which checks Python source files for errors";
    homepage = "https://github.com/PyCQA/pyflakes";
    changelog = "https://github.com/PyCQA/pyflakes/blob/${src.tag}/NEWS.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
    mainProgram = "pyflakes";
  };
}
