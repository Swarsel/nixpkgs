{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dbus,
  pkg-config,
  pkgs,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "sdbus";
  version = "0.14.2";

  src = fetchFromGitHub {
    owner = "python-sdbus";
    repo = "python-sdbus";
    tag = finalAttrs.version;
    hash = "sha256-vRz7RTSI5QjI48YnaC20mbOKl6+yXk/TrFicQ0MDR9Q=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ pkgs.systemd ];

  nativeCheckInputs = [
    pytestCheckHook
    dbus
  ];

  build-system = [ setuptools ];

  disabledTestPaths = [
    # try to access /var/lib/dbus/machine-id
    "test/test_proxies.py::TestFreedesktopDbus::test_connection"
    "test/test_sdbus_block.py::TestSync::test_sync"
  ];

  pyproject = true;
  pythonImportsCheck = [ "sdbus" ];

  meta = {
    description = "Modern Python library for D-Bus";
    homepage = "https://github.com/python-sdbus/python-sdbus";
    license = lib.licenses.lgpl2Plus;
    maintainers = with lib.maintainers; [ camelpunch ];
    platforms = lib.platforms.linux;
  };
})
