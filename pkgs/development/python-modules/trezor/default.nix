{
  lib,
  stdenv,
  # optional-dependencies
  bleak,
  buildPythonPackage,
  # dependencies
  click,
  construct,
  construct-classes,
  cryptography,
  fetchPypi,
  hatchling,
  hidapi,
  keyring,
  libusb1,
  mnemonic,
  noiseprotocol,
  pillow,
  platformdirs,
  pyqt5,
  pytest-random-order,
  pytestCheckHook,
  requests,
  shamir-mnemonic,
  slip10,
  typing-extensions,
  web3,
}:

buildPythonPackage rec {
  pname = "trezor";
  version = "0.20.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-TAmOIDFbJxZnOr3vQCgi5xiRAVmMfAPyN0ndIBDuJQQ=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-random-order
  ];

  postCheck = ''
    $out/bin/trezorctl --version
  '';

  build-system = [ hatchling ];

  dependencies = [
    click
    construct
    construct-classes
    cryptography
    keyring
    libusb1
    mnemonic
    noiseprotocol
    platformdirs
    requests
    shamir-mnemonic
    slip10
    typing-extensions
  ];

  disabledTestPaths = [
    "tests/test_stellar.py" # requires stellar-sdk
    "tests/test_firmware.py" # requires network downloads
  ];

  optional-dependencies = {
    ble = [ bleak ];
    ethereum = [ web3 ];
    extra = [ pillow ];
    # stellar = [ stellar-sdk ]; # missing in nixpkgs
    full = lib.flatten (lib.attrValues (lib.removeAttrs optional-dependencies [ "full" ]));
    hidapi = [ hidapi ];
    qt-widgets = [ pyqt5 ];
  };

  pyproject = true;
  pythonImportsCheck = [ "trezorlib" ];

  meta = {
    description = "Python library for communicating with Trezor Hardware Wallet";
    homepage = "https://github.com/trezor/trezor-firmware/tree/master/python";
    changelog = "https://github.com/trezor/trezor-firmware/blob/python/v${version}/python/CHANGELOG.md";
    license = lib.licenses.lgpl3Only;

    maintainers = with lib.maintainers; [
      np
      prusnak
      mmahut
    ];

    mainProgram = "trezorctl";
  };
}
