{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "html2text";
  version = "2025.4.15";

  src = fetchFromGitHub {
    owner = "Alir3z4";
    repo = "html2text";
    tag = version;
    hash = "sha256-SMdILvCVXMe3Tlf3kK54VfEKsQ/KvpBZK3xZ4zVwcfo=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  pyproject = true;
  pythonImportsCheck = [ "html2text" ];

  meta = {
    description = "Turn HTML into equivalent Markdown-structured text";
    homepage = "https://github.com/Alir3z4/html2text/";
    changelog = "https://github.com/Alir3z4/html2text/blob/${src.tag}/ChangeLog.rst";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    mainProgram = "html2text";
  };
}
