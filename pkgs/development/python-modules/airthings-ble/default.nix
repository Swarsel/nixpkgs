{
  lib,
  fetchFromGitHub,
  async-interrupt,
  bleak,
  bleak-retry-connector,
  buildPythonPackage,
  cbor2,
  poetry-core,
  pytest-cov-stub,
  pytestCheckHook,
  pythonOlder,
}:

buildPythonPackage rec {
  pname = "airthings-ble";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "vincegio";
    repo = "airthings-ble";
    tag = version;
    hash = "sha256-y6vpkq3u5JKImwxevMupUVVAclUcsyrqxoIOYRK0YGQ=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    async-interrupt
    bleak-retry-connector
    cbor2
  ]
  ++ lib.optionals (pythonOlder "3.14") [
    bleak
  ];

  pyproject = true;
  pythonImportsCheck = [ "airthings_ble" ];

  meta = {
    description = "Library for Airthings BLE devices";
    homepage = "https://github.com/vincegio/airthings-ble";
    changelog = "https://github.com/vincegio/airthings-ble/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
