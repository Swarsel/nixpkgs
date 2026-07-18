{
  lib,
  buildDunePackage,
  dune,
  stdune,
}:

buildDunePackage {
  inherit (dune) src version;
  pname = "dune-private-libs";
  propagatedBuildInputs = [ stdune ];
  dontAddPrefix = true;

  meta = {
    description = "Private libraries of Dune";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
