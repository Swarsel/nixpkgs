{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "paragraphs";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "ShayHill";
    repo = "paragraphs";
    tag = version;
    hash = "sha256-u5/oNOCLdvfQVEIEpraeNLjTUoh3eJQ6qSExnkzTmNw=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  pyproject = true;

  pythonImportsCheck = [
    "paragraphs"
  ];

  meta = {
    description = "Module to incorporate long strings";
    homepage = "https://github.com/ShayHill/paragraphs";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
