{
  lib,
  fetchFromGitHub,
  behave,
  buildPythonPackage,
  lxml,
  mock,
  pyparsing,
  pytestCheckHook,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "python-docx";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "python-openxml";
    repo = "python-docx";
    tag = "v${version}";
    hash = "sha256-5x2VmMiY5fZiXoswCDcs89olL0vbpGzmJZThrNS/SmI=";
  };

  nativeCheckInputs = [
    behave
    mock
    pyparsing
    pytestCheckHook
  ];

  postCheck = ''
    behave --format progress --stop --tags=-wip
  '';

  build-system = [ setuptools ];

  dependencies = [
    lxml
    typing-extensions
  ];

  disabledTests = [
    # https://github.com/python-openxml/python-docx/issues/1302
    "it_accepts_unicode_providing_there_is_no_encoding_declaration"
  ];

  pyproject = true;

  pytestFlags = [
    "-Wignore::DeprecationWarning"
  ];

  pythonImportsCheck = [ "docx" ];

  meta = {
    description = "Create and update Microsoft Word .docx files";
    homepage = "https://python-docx.readthedocs.io/";
    changelog = "https://github.com/python-openxml/python-docx/blob/v${version}/HISTORY.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ alexchapman ];
  };
}
