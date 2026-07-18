{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  deprecated,
  httpretty,
  mock,
  polling,
  pytestCheckHook,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "linode-api";
  version = "5.45.0";

  # Sources from Pypi exclude test fixtures
  src = fetchFromGitHub {
    owner = "linode";
    repo = "python-linode-api";
    tag = "v${version}";
    hash = "sha256-0FLF/LkU8SaR3itgMISbqOxmd4UZkGlTT3VDpmuv+QQ=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    mock
    httpretty
  ];

  build-system = [ setuptools ];

  dependencies = [
    requests
    polling
    deprecated
  ];

  disabledTestPaths = [
    # needs api token
    "test/integration"
  ];

  pyproject = true;
  pythonImportsCheck = [ "linode_api4" ];

  meta = {
    description = "Python library for the Linode API v4";
    homepage = "https://github.com/linode/python-linode-api";
    changelog = "https://github.com/linode/linode_api4-python/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ glenns ];
  };
}
