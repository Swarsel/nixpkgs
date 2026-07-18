{
  lib,
  fetchFromGitHub,
  aiocoap,
  aiohappyeyeballs,
  async-interrupt,
  bleak,
  bleak-retry-connector,
  buildPythonPackage,
  chacha20poly1305,
  chacha20poly1305-reuseable,
  commentjson,
  cryptography,
  orjson,
  poetry-core,
  pytest-aiohttp,
  pytestCheckHook,
  zeroconf,
}:

buildPythonPackage rec {
  pname = "aiohomekit";
  version = "3.2.20";

  src = fetchFromGitHub {
    owner = "Jc2k";
    repo = "aiohomekit";
    tag = version;
    hash = "sha256-iVLW7oaYJ2imVs0aMUpGbiCyE86JOaHZJr86ZGRkfLM=";
  };

  nativeCheckInputs = [
    pytest-aiohttp
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    aiocoap
    aiohappyeyeballs
    async-interrupt
    bleak
    bleak-retry-connector
    chacha20poly1305
    chacha20poly1305-reuseable
    commentjson
    cryptography
    orjson
    zeroconf
  ];

  disabledTestPaths = [
    # Tests require network access
    "tests/test_ip_pairing.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "aiohomekit" ];

  meta = {
    description = "Python module that implements the HomeKit protocol";

    longDescription = ''
      This Python library implements the HomeKit protocol for controlling
      Homekit accessories.
    '';

    homepage = "https://github.com/Jc2k/aiohomekit";
    changelog = "https://github.com/Jc2k/aiohomekit/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "aiohomekitctl";
  };
}
