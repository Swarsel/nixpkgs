{
  lib,
  stdenv,
  buildPythonPackage,
  # tests
  easyprocess,
  entrypoint2,
  fetchPypi,
  pillow,
  psutil,
  pytest-timeout,
  pytest-xdist,
  pytestCheckHook,
  replaceVars,
  # build-system
  setuptools,
  vncdo,
  xauth,
  xdpyinfo,
  xmessage,
  xorg-server,
  xvfb,
}:

buildPythonPackage rec {
  pname = "pyvirtualdisplay";
  version = "3.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-CXVbw86263JfsH7KVCX0PyNY078I4A0qm3kqGu3RYVk=";
    pname = "PyVirtualDisplay";
  };

  patches = lib.optionals stdenv.hostPlatform.isLinux [
    (replaceVars ./paths.patch {
      xauth = lib.getExe xauth;
      xdpyinfo = lib.getExe xdpyinfo;
    })
  ];

  doCheck = stdenv.hostPlatform.isLinux;

  nativeCheckInputs = [
    easyprocess
    entrypoint2
    pillow
    psutil
    pytest-timeout
    pytestCheckHook
    (vncdo.overridePythonAttrs { doCheck = false; })
    xorg-server
    xmessage
    xvfb
  ];

  build-system = [ setuptools ];
  pyproject = true;
  pytestFlags = [ "-v" ];

  meta = {
    description = "Python wrapper for Xvfb, Xephyr and Xvnc";
    homepage = "https://github.com/ponty/pyvirtualdisplay";
    license = lib.licenses.bsdOriginal;
    maintainers = with lib.maintainers; [ layus ];
  };
}
