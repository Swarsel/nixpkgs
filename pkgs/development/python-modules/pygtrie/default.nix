{
  lib,
  buildPythonPackage,
  fetchPypi,
}:
buildPythonPackage rec {
  pname = "pygtrie";
  version = "2.5.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-IDUUrYJutAPasdLi3dA04NFTS75NvgITuwWT9mvrpOI=";
  };

  format = "setuptools";

  meta = {
    description = "Trie data structure implementation";
    homepage = "https://github.com/mina86/pygtrie";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ kmein ];
  };
}
