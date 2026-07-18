{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "errbot";
  version = "6.2.1";

  src = fetchFromGitHub {
    owner = "errbotio";
    repo = "errbot";
    rev = finalAttrs.version;
    hash = "sha256-ufJUcQUn+BbfnYRXqLlThis70sY5VLdsZlag6390wqs=";
  };

  nativeCheckInputs = with python3.pkgs; [
    mock
    pytestCheckHook
  ];

  build-system = with python3.pkgs; [
    setuptools
  ];

  dependencies = with python3.pkgs; [
    ansi
    colorlog
    daemonize
    deepmerge
    dulwich
    flask
    irc
    jinja2
    markdown
    pyasn1
    pyasn1-modules
    pygments
    pygments-markdown-lexer
    pyopenssl
    requests
    setuptools
    slixmpp
    python-telegram-bot
    webtest
  ];

  disabledTests = [
    # require networking
    "test_backup"
    "test_broken_plugin"
    "test_plugin_cycle"
    "test_entrypoint_paths"
  ];

  pyproject = true;
  pythonImportsCheck = [ "errbot" ];
  pythonRelaxDeps = true;

  meta = {
    description = "Chatbot designed to be simple to extend with plugins written in Python";
    homepage = "http://errbot.io/";
    changelog = "https://github.com/errbotio/errbot/blob/${finalAttrs.version}/CHANGES.rst";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ hlad ];
    platforms = lib.platforms.linux;
    # flaky on darwin, "RuntimeError: can't start new thread"
    mainProgram = "errbot";
  };
})
