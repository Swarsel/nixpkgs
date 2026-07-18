{
  lib,
  fetchFromGitHub,
  bleak,
  bleak-retry-connector,
  buildHomeAssistantComponent,
  crc,
  ecdsa,
  jsonpath-ng,
  nix-update-script,
  protobuf6,
  pycryptodome,
  pytest-asyncio,
  pytest-mock,
  pytestCheckHook,
}:

buildHomeAssistantComponent rec {
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "rabits";
    repo = "ha-ef-ble";
    tag = "v${version}";
    hash = "sha256-LPu4Autma/1MOrfs6FG9cQZFL3kRofVPbScEEZjAi6w=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
    pytest-mock
  ];

  dependencies = [
    bleak
    bleak-retry-connector
    ecdsa
    crc
    protobuf6
    pycryptodome
  ];

  domain = "ef_ble";
  owner = "rabits";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Home Assistant component for EcoFlow BLE devices (local)";
    homepage = "https://github.com/rabits/ha-ef-ble";
    changelog = "https://github.com/rabits/ha-ef-ble/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ implr ];
  };
}
