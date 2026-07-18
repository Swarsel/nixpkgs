{
  lib,
  fetchFromGitHub,
  bitbox02,
  buildPythonPackage,
  cbor,
  ecdsa,
  hidapi,
  libusb1,
  mnemonic,
  pyaes,
  pyserial,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "hwi";
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "bitcoin-core";
    repo = "HWI";
    tag = version;
    hash = "sha256-sQqft+5M+X+91bFqpUrbDRrFzpe/l1+w+pnIHwqezR8=";
  };

  propagatedBuildInputs = [
    bitbox02
    cbor
    ecdsa
    hidapi
    libusb1
    mnemonic
    pyaes
    pyserial
    typing-extensions
  ];

  # Tests require to clone quite a few firmwares
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "hwilib" ];

  meta = {
    description = "Bitcoin Hardware Wallet Interface";
    homepage = "https://github.com/bitcoin-core/hwi";
    changelog = "https://github.com/bitcoin-core/HWI/releases/tag/${version}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ prusnak ];
  };
}
