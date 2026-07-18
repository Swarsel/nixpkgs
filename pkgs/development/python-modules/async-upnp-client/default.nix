{
  lib,
  stdenv,
  fetchFromGitHub,
  # dependencies
  aiohttp,
  buildPythonPackage,
  defusedxml,
  # tests
  pytest-aiohttp,
  pytest-asyncio,
  pytestCheckHook,
  python-didl-lite,
  # build-system
  setuptools,
  voluptuous,
}:

buildPythonPackage rec {
  pname = "async-upnp-client";
  version = "0.46.2";

  src = fetchFromGitHub {
    owner = "StevenLooman";
    repo = "async_upnp_client";
    tag = version;
    hash = "sha256-KJiEfu+JKDycBT14gFK4sBFCG3TN61DZEDth9y6CHp4=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-aiohttp
    pytest-asyncio
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    defusedxml
    python-didl-lite
    voluptuous
  ];

  disabledTestPaths = [
    # Tries to bind to multicast socket and fails to find proper interface
    "tests/test_ssdp_listener.py"
  ];

  disabledTests = [
    # socket.gaierror: [Errno -2] Name or service not known
    "test_async_get_local_ip"
    "test_get_local_ip"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ "test_deferred_callback_url" ];

  pyproject = true;
  pythonImportsCheck = [ "async_upnp_client" ];

  meta = {
    description = "Asyncio UPnP Client library for Python";
    homepage = "https://github.com/StevenLooman/async_upnp_client";
    changelog = "https://github.com/StevenLooman/async_upnp_client/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hexa ];
    mainProgram = "upnp-client";
  };
}
