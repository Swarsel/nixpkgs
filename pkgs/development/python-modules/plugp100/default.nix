{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  certifi,
  cryptography,
  jsons,
  pytest-asyncio,
  # Test inputs
  pytestCheckHook,
  requests,
  scapy,
  semantic-version,
  urllib3,
}:

buildPythonPackage (finalAttrs: {
  pname = "plugp100";
  version = "5.1.5";

  src = fetchFromGitHub {
    owner = "petretiandrea";
    repo = "plugp100";
    tag = finalAttrs.version;
    sha256 = "sha256-bPjgyScHxiUke/M5S6BOw7df7wbNuSy5ouVIK5guWxw=";
  };

  propagatedBuildInputs = [
    certifi
    jsons
    requests
    aiohttp
    semantic-version
    cryptography
    scapy
    urllib3
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
  ];

  disabledTestPaths = [
    "tests/integration/"
    "tests/unit/hub_child/"
    "tests/unit/test_plug_strip.py"
    "tests/unit/test_hub.py "
    "tests/unit/test_klap_protocol.py"
  ];

  format = "setuptools";

  meta = {
    description = "Python library to control Tapo Plug P100 devices";
    homepage = "https://github.com/petretiandrea/plugp100";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ pyle ];
  };
})
