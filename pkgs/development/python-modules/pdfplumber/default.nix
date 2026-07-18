{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  jupyterlab,
  nbexec,
  pandas,
  pandas-stubs,
  pdfminer-six,
  pillow,
  pkgs,
  pypdfium2,
  pytest-cov-stub,
  pytest-parallel,
  pytestCheckHook,
  setuptools,
  types-pillow,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "pdfplumber";
  version = "0.11.9";

  src = fetchFromGitHub {
    owner = "jsvine";
    repo = "pdfplumber";
    tag = "v${version}";
    hash = "sha256-vOtr+9qRpd+VXUpVL2whflbA7Gchd4yuA47FBl5BYfE=";
  };

  nativeCheckInputs = [
    pkgs.ghostscript
    jupyterlab
    nbexec
    pandas
    pandas-stubs
    pytest-cov-stub
    pytest-parallel
    pytestCheckHook
    types-pillow
    writableTmpDirAsHomeHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    pdfminer-six
    pillow
    pypdfium2
  ];

  disabledTestPaths = [
    # AssertionError
    "tests/test_convert.py::Test::test_cli_csv"
    "tests/test_convert.py::Test::test_cli_csv_exclude"
    "tests/test_convert.py::Test::test_csv"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pdfplumber" ];
  pythonRelaxDeps = [ "pdfminer.six" ];

  meta = {
    description = "Plumb a PDF for detailed information about each char, rectangle, line, et cetera — and easily extract text and tables";
    homepage = "https://github.com/jsvine/pdfplumber";
    changelog = "https://github.com/jsvine/pdfplumber/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ happysalada ];
    mainProgram = "pdfplumber";
  };
}
