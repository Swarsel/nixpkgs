{
  lib,
  fetchFromGitHub,
  # dependencies
  beautifulsoup4,
  buildPythonPackage,
  compressed-rtf,
  ebcdic,
  olefile,
  # tests
  pytestCheckHook,
  red-black-tree-mod,
  rtfde,
  # build-system
  setuptools,
  tzlocal,
}:

buildPythonPackage (finalAttrs: {
  pname = "extract-msg";
  version = "0.55.0";

  src = fetchFromGitHub {
    owner = "TeamMsgExtractor";
    repo = "msg-extractor";
    tag = "v${finalAttrs.version}";
    hash = "sha256-n/v3ubgzWlWqLXZfy1O7+FvTJoLMtgL7DFPL39SZnfM=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    beautifulsoup4
    compressed-rtf
    ebcdic
    olefile
    red-black-tree-mod
    rtfde
    tzlocal
  ];

  enabledTestPaths = [ "extract_msg_tests/*.py" ];
  pyproject = true;
  pythonImportsCheck = [ "extract_msg" ];

  pythonRelaxDeps = [
    "beautifulsoup4"
    "ebcdic"
  ];

  meta = {
    description = "Extracts emails and attachments saved in Microsoft Outlook's .msg files";
    homepage = "https://github.com/TeamMsgExtractor/msg-extractor";
    changelog = "https://github.com/TeamMsgExtractor/msg-extractor/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ fab ];
  };
})
