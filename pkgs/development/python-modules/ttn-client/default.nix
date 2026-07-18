{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  hatchling,
  pytest-asyncio,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "ttn-client";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "angelnu";
    repo = "thethingsnetwork_python_client";
    tag = "v${version}";
    hash = "sha256-n5AvHE9oe7+vqxUsqqGeVcENU8+I0y0jikbulAHAR3Q=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ hatchling ];
  dependencies = [ aiohttp ];

  disabledTests = [
    # Test require network access
    "test_connection_auth_error"
  ];

  pyproject = true;
  pythonImportsCheck = [ "ttn_client" ];

  meta = {
    description = "Module to fetch/receive and parse uplink messages from The Thinks Network";
    homepage = "https://github.com/angelnu/thethingsnetwork_python_client";
    changelog = "https://github.com/angelnu/thethingsnetwork_python_client/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
