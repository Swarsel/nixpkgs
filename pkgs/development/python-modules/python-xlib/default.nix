{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  libx11,
  mock,
  pytestCheckHook,
  setuptools-scm,
  setuptools_80,
  six,
  util-linux,
  xauth,
  xvfb,
}:

buildPythonPackage rec {
  pname = "python-xlib";
  version = "0.33";

  src = fetchFromGitHub {
    owner = "python-xlib";
    repo = "python-xlib";
    tag = version;
    hash = "sha256-u06OWlMIOUzHOVS4hvm72jGgTSXWUqMvEQd8bTpFog0=";
  };

  buildInputs = [ libx11 ];
  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    pytestCheckHook
    mock
    util-linux
    xauth
    xvfb
  ];

  build-system = [
    (setuptools-scm.override { setuptools = setuptools_80; })
  ];

  dependencies = [ six ];

  disabledTestPaths = [
    # requires x session
    "test/test_xlib_display.py"
  ];

  pyproject = true;

  meta = {
    description = "Fully functional X client library for Python programs";
    homepage = "https://github.com/python-xlib/python-xlib";
    changelog = "https://github.com/python-xlib/python-xlib/releases/tag/${version}";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ ];
  };
}
