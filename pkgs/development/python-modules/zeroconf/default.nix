{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  ifaddr,
  poetry-core,
  pytest-asyncio,
  pytest-codspeed,
  pytest-cov-stub,
  pytest-timeout,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "zeroconf";
  version = "0.150.0";

  src = fetchFromGitHub {
    owner = "jstasiak";
    repo = "python-zeroconf";
    tag = finalAttrs.version;
    hash = "sha256-Etk8sQZotwmsM6HkArAl2sDZop77wTAcE4aUSIoM1ds=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-codspeed
    pytest-cov-stub
    pytest-timeout
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;

  build-system = [
    cython
    poetry-core
    setuptools
  ];

  dependencies = [ ifaddr ];

  disabledTests = [
    # OSError: [Errno 19] No such device
    "test_close_multiple_times"
    "test_integration_with_listener_ipv6"
    "test_launch_and_close"
    "test_launch_and_close_context_manager"
    "test_launch_and_close_v4_v6"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "zeroconf"
    "zeroconf.asyncio"
  ];

  meta = {
    description = "Python implementation of multicast DNS service discovery";
    homepage = "https://github.com/python-zeroconf/python-zeroconf";
    changelog = "https://github.com/python-zeroconf/python-zeroconf/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.lgpl21Only;
    maintainers = [ ];
  };
})
