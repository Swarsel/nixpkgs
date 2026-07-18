{
  lib,
  buildPythonPackage,
  fetchPypi,
  pillow,
  qrcode,
  setuptools,
}:
buildPythonPackage rec {
  pname = "qrcode-terminal";
  version = "0.8";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Hitp5mK5NG6Y3ZWYMDPp1Dz/BkPYr9oSYF9RVCjmZsA=";
  };

  # have no test
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    qrcode
    pillow
  ];

  pyproject = true;
  pythonImportsCheck = [ "qrcode_terminal" ];

  meta = {
    description = "Display QRCode in Terminal";
    homepage = "https://github.com/alishtory/qrcode-terminal";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "qrcode-terminal-py";
  };
}
