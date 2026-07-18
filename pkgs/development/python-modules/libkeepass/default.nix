{
  lib,
  buildPythonPackage,
  colorama,
  fetchPypi,
  lxml,
  pycryptodome,
}:

buildPythonPackage rec {
  pname = "libkeepass";
  version = "0.3.1.post1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0pwg7n9xqcjia1qmz6g48h5s31slh3mxmcqag73gq4zhl4xb6bai";
  };

  propagatedBuildInputs = [
    lxml
    pycryptodome
    colorama
  ];

  # No tests on PyPI
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Library to access KeePass 1.x/KeePassX (v3) and KeePass 2.x (v4) files";
    homepage = "https://github.com/libkeepass/libkeepass";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ jqueiroz ];
  };
}
