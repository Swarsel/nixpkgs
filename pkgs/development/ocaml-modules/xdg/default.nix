{
  lib,
  buildDunePackage,
  dune,
}:

buildDunePackage {
  inherit (dune) src version;
  pname = "xdg";
  dontAddPrefix = true;

  meta = {
    inherit (dune.meta) homepage maintainers;
    description = "XDG Base Directory Specification";
    license = lib.licenses.mit;
  };
}
