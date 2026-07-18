{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  lxml,
  pkg-config,
  psutil,
  pytestCheckHook,
  setuptools,
  systemd,
}:

buildPythonPackage rec {
  pname = "pystemd";
  version = "0.15.3";

  src = fetchFromGitHub {
    owner = "systemd";
    repo = "pystemd";
    tag = "v${version}";
    hash = "sha256-qFBa2hIcF0hyb+QyVpFG0qOpWsVVVTGCqgfChic6JCI=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [ systemd ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  # Having the source root in `sys.path` causes import issues
  preCheck = ''
    cd tests
  '';

  build-system = [
    setuptools
    cython
  ];

  dependencies = [
    lxml
    psutil
  ];

  disabledTestPaths = [
    "test_version.py" # Requires cstq which is not in nixpkgs
    "test_pickle.py" # fails with "Could not open a bus to DBus"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pystemd" ];

  meta = {
    description = ''
      Thin Cython-based wrapper on top of libsystemd, focused on exposing the
      dbus API via sd-bus in an automated and easy to consume way
    '';

    homepage = "https://github.com/facebookincubator/pystemd";
    changelog = "https://github.com/systemd/pystemd/releases/tag/${src.tag}";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ flokli ];
  };
}
