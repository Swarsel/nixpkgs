{
  lib,
  fetchFromGitHub,
  base36,
  buildPythonPackage,
  chacha20poly1305-reuseable,
  cryptography,
  h11,
  orjson,
  pyqrcode,
  pytest-asyncio,
  pytest-timeout,
  pytestCheckHook,
  pythonAtLeast,
  setuptools,
  zeroconf,
}:

buildPythonPackage (finalAttrs: {
  pname = "hap-python";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "ikalchev";
    repo = "HAP-python";
    tag = finalAttrs.version;
    hash = "sha256-+EhxoO5X/ANGh008WE0sJeBsu8SRnuds3hXGxNWpKnk=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-timeout
    pytestCheckHook
  ]
  ++ lib.flatten (builtins.attrValues finalAttrs.passthru.optional-dependencies);

  build-system = [ setuptools ];

  dependencies = [
    chacha20poly1305-reuseable
    cryptography
    h11
    orjson
    zeroconf
  ];

  disabledTests = lib.optionals (pythonAtLeast "3.14") [
    # https://github.com/ikalchev/HAP-python/issues/490
    "test_start_from_sync"
  ];

  optional-dependencies.QRCode = [
    base36
    pyqrcode
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyhap" ];

  meta = {
    description = "HomeKit Accessory Protocol implementation";
    homepage = "https://github.com/ikalchev/HAP-python";
    changelog = "https://github.com/ikalchev/HAP-python/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ oro ];
  };
})
