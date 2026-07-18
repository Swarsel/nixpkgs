{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  isPyPy,
  pytestCheckHook,
  python,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pycodestyle";
  version = "2.14.0";

  src = fetchFromGitHub {
    owner = "PyCQA";
    repo = "pycodestyle";
    tag = version;
    hash = "sha256-1EEQp/QEulrdU9tTe28NerQ33IWlAiSlicpmNYciW88=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  # https://github.com/PyCQA/pycodestyle/blob/2.14.0/tox.ini#L16
  postCheck = ''
    ${python.interpreter} -m pycodestyle --statistics pycodestyle.py
  '';

  build-system = [ setuptools ];

  disabledTests = lib.optionals isPyPy [
    # PyPy reports a SyntaxError instead of ValueError
    "test_check_nullbytes"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pycodestyle" ];

  meta = {
    description = "Python style guide checker";
    homepage = "https://pycodestyle.pycqa.org/";
    changelog = "https://github.com/PyCQA/pycodestyle/blob/${src.tag}/CHANGES.txt";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kamadorueda ];
    mainProgram = "pycodestyle";
  };
}
