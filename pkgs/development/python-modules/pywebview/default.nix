{
  lib,
  stdenv,
  fetchFromGitHub,
  bottle,
  buildPythonPackage,
  proxy-tools,
  pyobjc-core,
  pyobjc-framework-Cocoa,
  pyobjc-framework-Quartz,
  pyobjc-framework-Security,
  pyobjc-framework-WebKit,
  pyside6,
  qtpy,
  setuptools-scm,
  six,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "pywebview";
  version = "6.1";

  src = fetchFromGitHub {
    owner = "r0x0r";
    repo = "pywebview";
    tag = version;
    hash = "sha256-vqdJRxZbHNu2Sq318RnJjzDjYRRCSiO72WM+flKwW7g=";
  };

  build-system = [ setuptools-scm ];

  dependencies = [
    bottle
    pyside6
    proxy-tools
    qtpy
    six
    typing-extensions
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    pyobjc-core
    pyobjc-framework-Cocoa
    pyobjc-framework-Quartz
    pyobjc-framework-Security
    pyobjc-framework-WebKit
  ];

  pyproject = true;
  pythonImportsCheck = [ "webview" ];

  meta = {
    description = "Lightweight cross-platform wrapper around a webview";
    homepage = "https://github.com/r0x0r/pywebview";
    license = lib.licenses.bsd3;

    # contains committed jar and dll files
    sourceProvenance = with lib.sourceTypes; [
      binaryBytecode
      binaryNativeCode
    ];

    maintainers = with lib.maintainers; [ jojosch ];
  };
}
