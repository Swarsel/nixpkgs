{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cryptography,
  freezegun,
  ifaddr,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "xknx";
  version = "3.16.0";

  src = fetchFromGitHub {
    owner = "XKNX";
    repo = "xknx";
    tag = finalAttrs.version;
    hash = "sha256-884iWQynTRBauJR10CzgkveoD9//Dq+mpvywtSnmT+c=";
  };

  nativeCheckInputs = [
    freezegun
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    cryptography
    ifaddr
  ];

  disabledTests = [
    # Test requires network access
    "test_routing_indication_multicast"
    "test_scan_timeout"
    "test_start_secure_routing_explicit_keyring"
    "test_start_secure_routing_knx_keys"
    "test_start_secure_routing_manual"
  ];

  pyproject = true;
  pytestFlags = [ "--asyncio-mode=auto" ];
  pythonImportsCheck = [ "xknx" ];

  meta = {
    description = "KNX Library Written in Python";

    longDescription = ''
      XKNX is an asynchronous Python library for reading and writing KNX/IP
      packets. It provides support for KNX/IP routing and tunneling devices.
    '';

    homepage = "https://github.com/XKNX/xknx";
    changelog = "https://github.com/XKNX/xknx/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    platforms = lib.platforms.linux;
  };
})
