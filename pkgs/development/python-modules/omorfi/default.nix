{
  lib,
  buildPythonPackage,
  hfst,
  pkgs,
}:

buildPythonPackage rec {
  inherit (pkgs.omorfi) src version;
  pname = "omorfi";
  # Fixes some improper import paths
  patches = [ ./importfix.patch ];
  propagatedBuildInputs = [ hfst ];
  format = "setuptools";
  # Apply patch relative to source/src
  patchFlags = [ "-p3" ];
  sourceRoot = "${src.name}/src/python";

  meta = {
    description = "Python interface for Omorfi";
    homepage = "https://github.com/flammie/omorfi";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ lurkki ];
  };
}
