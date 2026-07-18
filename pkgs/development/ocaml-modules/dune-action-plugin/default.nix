{
  lib,
  buildDunePackage,
  dune,
  dune-glob,
  dune-private-libs,
  dune-rpc,
}:

buildDunePackage {
  inherit (dune) src version;
  pname = "dune-action-plugin";

  propagatedBuildInputs = [
    dune-glob
    dune-private-libs
    dune-rpc
  ];

  dontAddPrefix = true;

  meta = {
    inherit (dune.meta) homepage;
    description = "API for writing dynamic Dune actions";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
