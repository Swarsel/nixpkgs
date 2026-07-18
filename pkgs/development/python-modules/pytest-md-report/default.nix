{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytablewriter,
  pytest,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  tcolorpy,
  typepy,
}:

buildPythonPackage rec {
  pname = "pytest-md-report";
  version = "0.8.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-yOO38fkaDo59G5RuGyJPTzkYfaDfL4EnMTYaQ2oX9HI=";
    pname = "pytest_md_report";
  };

  buildInputs = [ pytest ];

  propagatedBuildInputs = [
    pytablewriter
    tcolorpy
    typepy
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  pyproject = true;
  pythonImportsCheck = [ "pytest_md_report" ];

  meta = {
    description = "Pytest plugin to make a test results report with Markdown table format";
    homepage = "https://github.com/thombashi/pytest-md-report";
    changelog = "https://github.com/thombashi/pytest-md-report/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ rrbutani ];
  };
}
