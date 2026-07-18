{
  lib,
  stdenv,
  buildPythonPackage,
  fetchPypi,
  pkgs,
  replaceVars,
  setuptools,
}:

buildPythonPackage rec {
  pname = "streamcontroller-streamdeck";
  version = "0.1.7";

  src = fetchPypi {
    inherit version;
    hash = "sha256-n8MYXsuWGSfOTnYrFItwkQaZlBQvPOwt1GdNP4MDjnY=";
    pname = "streamcontroller_streamdeck";
  };

  patches = [
    # substitute libusb path
    (replaceVars ./hardcode-libusb.patch {
      libusb = "${pkgs.hidapi}/lib/libhidapi-libusb${stdenv.hostPlatform.extensions.sharedLibrary}";
    })
  ];

  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "StreamDeck" ];

  meta = {
    # This is a fork of abcminiuser/python-elgato-streamdeck targeted at StreamController.
    description = "Python library to control the Elgato Stream Deck";
    homepage = "https://github.com/StreamController/streamcontroller-python-elgato-streamdeck";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      majiir
      sifmelcara
    ];
  };
}
