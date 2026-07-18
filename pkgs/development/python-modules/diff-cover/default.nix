{
  lib,
  buildPythonPackage,
  chardet,
  fetchPypi,
  jinja2,
  jinja2-pluralize,
  pluggy,
  poetry-core,
  pycodestyle,
  pyflakes,
  pygments,
  pylint,
  pytest-datadir,
  pytest-mock,
  pytestCheckHook,
  tomli,
}:

buildPythonPackage rec {
  pname = "diff-cover";
  version = "10.2.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-Yb+DAl8QUQx272pYIGgM9hubl06Pgd5wxXrJJvpjhyo=";
    pname = "diff_cover";
  };

  nativeCheckInputs = [
    pycodestyle
    pyflakes
    pylint
    pytest-datadir
    pytest-mock
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    chardet
    jinja2
    jinja2-pluralize
    pluggy
    pygments
    tomli
  ];

  disabledTests = [
    # Tests check for flake8
    "file_does_not_exist"
    # Comparing console output doesn't work reliable
    "console"
    # Assertion failure
    "test_html_with_external_css"
    "test_style_defs"
  ];

  pyproject = true;
  pythonImportsCheck = [ "diff_cover" ];

  meta = {
    description = "Automatically find diff lines that need test coverage";
    homepage = "https://github.com/Bachmann1234/diff-cover";
    changelog = "https://github.com/Bachmann1234/diff_cover/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dzabraev ];
  };
}
