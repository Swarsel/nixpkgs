{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  exceptiongroup,
  glibcLocales,
  pygobject3,
  pyserial,
  pytestCheckHook,
  pythonOlder,
  pyzmq,
  setuptools,
  setuptools-scm,
  tornado,
  trio,
  twisted,
  typing-extensions,
  wcwidth,
}:

buildPythonPackage rec {
  pname = "urwid";
  version = "3.0.5";

  src = fetchFromGitHub {
    owner = "urwid";
    repo = "urwid";
    tag = version;
    hash = "sha256-9ajcpyQTSASz8A4eM78vPjL+9Rk07Q30JmIrSx0Crpo=";
  };

  postPatch = ''
    sed -i '/addopts =/d' pyproject.toml
  '';

  env.LC_ALL = "en_US.UTF8";

  nativeCheckInputs = [
    glibcLocales
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    typing-extensions
    wcwidth
  ];

  disabledTestPaths = [
    # expect call hangs
    "tests/test_vterm.py"
  ];

  disabledTests = [
    # Flaky tests
    "TwistedEventLoopTest"
  ];

  enabledTestPaths = [ "tests" ];

  optional-dependencies = {
    curses = [ ];
    glib = [ pygobject3 ];
    lcd = [ pyserial ];
    serial = [ pyserial ];
    tornado = [ tornado ];
    trio = [ trio ] ++ lib.optionals (pythonOlder "3.11") [ exceptiongroup ];
    twisted = [ twisted ];
    zmq = [ pyzmq ];
  };

  pyproject = true;
  pythonImportsCheck = [ "urwid" ];

  meta = {
    description = "Full-featured console (xterm et al.) user interface library";
    homepage = "https://urwid.org/";
    changelog = "https://github.com/urwid/urwid/releases/tag/${src.tag}";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ ];
    downloadPage = "https://github.com/urwid/urwid";
  };
}
