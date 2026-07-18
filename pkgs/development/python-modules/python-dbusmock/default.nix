{
  lib,
  fetchFromGitHub,
  bluez,
  buildPythonPackage,
  dbus,
  # dependencies
  dbus-python,
  gobject-introspection,
  networkmanager,
  pygobject3,
  pytestCheckHook,
  runCommand,
  # build-system
  setuptools,
  setuptools-scm,
  # checks
  doCheck ? true,
}:

let
  # Cannot just add it to path in preCheck since that attribute will be passed to
  # mkDerivation even with doCheck = false, causing a dependency cycle.
  pbap-client = runCommand "pbap-client" { } ''
    mkdir -p "$out/bin"
    ln -s "${bluez.test}/test/pbap-client" "$out/bin/pbap-client"
  '';
in
buildPythonPackage rec {
  inherit doCheck;
  pname = "python-dbusmock";
  version = "0.37.2";

  src = fetchFromGitHub {
    owner = "martinpitt";
    repo = "python-dbusmock";
    tag = version;
    hash = "sha256-Q149NcbpbIgXCd7WujALC9I9vAM/tZh+enTJh0d84Kg=";
  };

  nativeCheckInputs = [
    dbus
    gobject-introspection
    pygobject3
    bluez
    pbap-client
    networkmanager
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [ dbus-python ];

  disabledTests = [
    # wants to call upower, which is a reverse-dependency
    "test_dbusmock_test_template"
    # Failed to execute program org.TestSystem: No such file or directory
    "test_system_service_activation"
    "test_session_service_activation"
  ];

  pyproject = true;

  meta = {
    description = "Mock D-Bus objects for tests";
    homepage = "https://github.com/martinpitt/python-dbusmock";
    changelog = "https://github.com/martinpitt/python-dbusmock/releases/tag/${src.tag}";
    license = lib.licenses.lgpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
}
