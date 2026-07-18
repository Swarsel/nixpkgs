{
  lib,
  buildDunePackage,
  dune,
  dune-private-libs,
}:

buildDunePackage {
  inherit (dune) src version;
  pname = "dune-site";
  propagatedBuildInputs = [ dune-private-libs ];
  dontAddPrefix = true;

  meta = {
    inherit (dune.meta) homepage;
    description = "Library for embedding location information inside executable and libraries";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
