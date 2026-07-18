{
  lib,
  buildDunePackage,
  dune,
}:

buildDunePackage {
  inherit (dune) src version;
  pname = "chrome-trace";
  dontAddPrefix = true;

  meta = {
    inherit (dune.meta) homepage;
    description = "Chrome trace event generation library";
    license = lib.licenses.mit;
  };
}
