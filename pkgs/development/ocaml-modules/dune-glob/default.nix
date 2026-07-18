{
  lib,
  buildDunePackage,
  dune,
  dune-private-libs,
  re,
}:

buildDunePackage {
  inherit (dune) src version;
  pname = "dune-glob";

  propagatedBuildInputs = [
    dune-private-libs
    re
  ];

  dontAddPrefix = true;

  meta = {
    inherit (dune.meta) homepage;
    description = "Glob string matching language supported by dune";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
