{
  lib,
  buildPythonPackage,
  cmdline,
  importlib-metadata,
  mock,
  pytest,
  pytest-fixture-config,
  pytest-shutil,
  pytestCheckHook,
  setuptools,
  virtualenv,
}:

buildPythonPackage {
  inherit (pytest-fixture-config) version src patches;
  pname = "pytest-virtualenv";

  postPatch = ''
    cd pytest-virtualenv
  '';

  buildInputs = [ pytest ];

  nativeCheckInputs = [
    cmdline
    mock
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    importlib-metadata
    pytest-fixture-config
    pytest-shutil
    virtualenv
  ];

  # Don't run integration tests
  disabledTestPaths = [ "tests/integration/*" ];
  pyproject = true;

  meta = {
    description = "Create a Python virtual environment in your test that cleans up on teardown. The fixture has utility methods to install packages and list what’s installed";
    homepage = "https://github.com/manahl/pytest-plugins";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ryansydnor ];
  };
}
