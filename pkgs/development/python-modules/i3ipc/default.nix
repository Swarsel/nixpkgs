{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  coreutils,
  fontconfig,
  i3,
  pytest-asyncio,
  pytest-timeout,
  pytest-xvfb,
  pytestCheckHook,
  python-xlib,
  setuptools,
  writableTmpDirAsHomeHook,
  xdpyinfo,
  xvfb,
}:

buildPythonPackage rec {
  pname = "i3ipc";
  version = "2.2.1";

  src = fetchFromGitHub {
    owner = "altdesktop";
    repo = "i3ipc-python";
    tag = "v${version}";
    hash = "sha256-JRwipvIF1zL/x2A+xEJKEFV6BlDnv2Xt/eyIzVrSf40=";
  };

  patches = [
    # Upstream expects a very old version of pytest-asyncio. This patch correctly
    # decorates async fixtures using pytest-asyncio and configures `loop_scope`
    # where needed.
    ./fix-async-tests.patch
  ];

  postPatch = ''
    substituteInPlace test/i3.config \
      --replace-fail /bin/true ${coreutils}/bin/true
  '';

  # Fontconfig error: Cannot load default config file
  env.FONTCONFIG_FILE = "${fontconfig.out}/etc/fonts/fonts.conf";

  nativeCheckInputs = [
    pytestCheckHook
    writableTmpDirAsHomeHook
    pytest-asyncio
    pytest-timeout
    pytest-xvfb
    i3
    xdpyinfo
    xvfb
  ];

  build-system = [ setuptools ];
  dependencies = [ python-xlib ];

  disabledTestPaths = [
    # Timeout
    "test/test_shutdown_event.py::TestShutdownEvent::test_shutdown_event_reconnect"
    "test/aio/test_shutdown_event.py::TestShutdownEvent::test_shutdown_event_reconnect"
    # Flaky
    "test/test_window.py::TestWindow::test_detailed_window_event"
    "test/aio/test_workspace.py::TestWorkspace::test_workspace"
  ];

  pyproject = true;
  pythonImportsCheck = [ "i3ipc" ];

  meta = {
    description = "Improved Python library to control i3wm and sway";
    homepage = "https://github.com/altdesktop/i3ipc-python";
    changelog = "https://github.com/altdesktop/i3ipc-python/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
  };
}
