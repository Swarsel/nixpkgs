{
  lib,
  stdenv,
  fetchFromGitHub,
  autocommand,
  beautifulsoup4,
  buildPythonPackage,
  cherrypy,
  feedparser,
  icmplib,
  ifconfig-parser,
  importlib-resources,
  jaraco-collections,
  jaraco-email,
  jaraco-functools,
  jaraco-logging,
  jaraco-text,
  jsonpickle,
  keyring,
  mechanize,
  more-itertools,
  net-tools,
  path,
  pathvalidate,
  pyparsing,
  pytest-responses,
  pytestCheckHook,
  python-dateutil,
  requests,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "jaraco-net";
  version = "10.2.3";

  src = fetchFromGitHub {
    owner = "jaraco";
    repo = "jaraco.net";
    tag = "v${version}";
    hash = "sha256-yZbiCGUZqJQdV3/vtNLs+B9ZDin2PH0agR4kYvB5HxA=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    cherrypy
    importlib-resources
    pyparsing
    pytest-responses
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ net-tools ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    autocommand
    more-itertools
    beautifulsoup4
    mechanize
    keyring
    requests
    feedparser
    icmplib
    jaraco-text
    jaraco-logging
    jaraco-email
    jaraco-functools
    jaraco-collections
    path
    python-dateutil
    pathvalidate
    jsonpickle
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ ifconfig-parser ];

  disabledTestPaths = [
    # require networking
    "jaraco/net/icmp.py"
    "jaraco/net/ntp.py"
    "jaraco/net/scanner.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "jaraco.net" ];

  meta = {
    description = "Networking tools by jaraco";
    homepage = "https://github.com/jaraco/jaraco.net";
    changelog = "https://github.com/jaraco/jaraco.net/blob/${src.tag}/NEWS.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
