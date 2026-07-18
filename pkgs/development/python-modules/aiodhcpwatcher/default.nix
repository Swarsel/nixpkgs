{
  lib,
  fetchFromGitHub,
  # tests
  blockbuster,
  buildPythonPackage,
  # build-system
  poetry-core,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  # dependencies
  scapy,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "aiodhcpwatcher";
  version = "1.2.7";

  src = fetchFromGitHub {
    owner = "bdraco";
    repo = "aiodhcpwatcher";
    tag = "v${finalAttrs.version}";
    hash = "sha256-a6svFLu0nmVVVVCg/evdmygTPj8VP+mjKTaaZGA0TQk=";
  };

  nativeCheckInputs = [
    blockbuster
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  build-system = [ poetry-core ];
  dependencies = [ scapy ];
  pyproject = true;
  pythonImportsCheck = [ "aiodhcpwatcher" ];

  meta = {
    description = "Watch for DHCP packets with asyncio";
    homepage = "https://github.com/bdraco/aiodhcpwatcher";
    changelog = "https://github.com/bdraco/aiodhcpwatcher/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hexa ];
    platforms = lib.platforms.linux;
  };
})
