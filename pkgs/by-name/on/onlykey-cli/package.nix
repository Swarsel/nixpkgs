{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "onlykey-cli";
  version = "1.2.10";

  src = fetchPypi {
    inherit version;
    hash = "sha256-ZmQnyZx9YlIIxMMdZ0U2zb+QANfcwrtG7iR1LpgzmBQ=";
    pname = "onlykey";
  };

  # Requires having the physical onlykey (a usb security key)
  doCheck = false;

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    aenum
    ecdsa
    hidapi
    onlykey-solo-python
    prompt-toolkit
    pynacl
    six
  ];

  pyproject = true;
  pythonImportsCheck = [ "onlykey.client" ];

  pythonRemoveDeps = [
    "Cython" # don't know why cython is listed as a runtime dependency, let's just remove it
  ];

  meta = {
    description = "OnlyKey client and command-line tool";
    homepage = "https://github.com/trustcrypto/python-onlykey";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ranfdev ];
    mainProgram = "onlykey-cli";
  };
}
