{
  lib,
  fetchFromGitHub,
  python3,
}:
python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "textlsp";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "hangyav";
    repo = "textLSP";
    tag = "v${finalAttrs.version}";
    hash = "sha256-euzihVBwpCgLD74SDOPD5P3X3vhEIBd4pP5EyVhPccQ=";
  };

  build-system = [ python3.pkgs.setuptools ];

  dependencies = with python3.pkgs; [
    pygls
    lsprotocol
    language-tool-python
    tree-sitter
    gitpython
    appdirs
    openai
    sortedcontainers
    langdetect
    ollama
  ];

  format = "setuptools";

  meta = {
    description = "Language server for text spell and grammar check with various tools";
    homepage = "https://github.com/hangyav/textLSP/tree/main";
    changelog = "https://github.com/hangyav/textLSP/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ justdeeevin ];
    platforms = lib.platforms.all;
    mainProgram = "textlsp";
  };
})
