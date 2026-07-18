{
  lib,
  buildPythonPackage,
  fetchPypi,
  flit-core,
}:

buildPythonPackage rec {
  pname = "deep-chainmap";
  version = "0.2.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-lrCg6GGxjq/Y3t1c1HpJuaP+XVvVrOcB5aVaem5E/I8=";
    pname = "deep_chainmap";
  };

  # Tests are not published to pypi
  doCheck = false;
  build-system = [ flit-core ];
  pyproject = true;
  pythonImportsCheck = [ "deep_chainmap" ];

  # See the guide for more information: https://nixos.org/nixpkgs/manual/#chap-meta
  meta = {
    description = "Recursive subclass of ChainMap";
    homepage = "https://github.com/neutrinoceros/deep_chainmap";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ rehno-lindeque ];
  };
}
