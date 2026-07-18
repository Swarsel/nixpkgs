{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  mysqlclient,
  psutil,
  pylibmc,
  pytest,
  pytestCheckHook,
  requests,
  setuptools-scm,
  toml,
  zc-lockfile,
}:

buildPythonPackage rec {
  pname = "pytest-services";
  version = "2.2.2";

  src = fetchFromGitHub {
    owner = "pytest-dev";
    repo = "pytest-services";
    tag = "v${version}";
    hash = "sha256-kWgqb7+3/hZKUz7B3PnfxHZq6yU3JUeJ+mruqrMD/NE=";
  };

  buildInputs = [ pytest ];

  nativeCheckInputs = [
    mysqlclient
    pylibmc
    pytestCheckHook
  ];

  # Tests use sockets
  __darwinAllowLocalNetworking = true;

  build-system = [
    setuptools-scm
    toml
  ];

  dependencies = [
    requests
    psutil
    zc-lockfile
  ];

  disabledTests = [
    # Tests require binaries and additional parts
    "test_memcached"
    "test_mysql"
    "test_xvfb"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pytest_services" ];

  meta = {
    description = "Services plugin for pytest testing framework";
    homepage = "https://github.com/pytest-dev/pytest-services";
    changelog = "https://github.com/pytest-dev/pytest-services/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
