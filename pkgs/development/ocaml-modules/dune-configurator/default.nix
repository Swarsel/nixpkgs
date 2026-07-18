{
  lib,
  buildDunePackage,
  csexp,
  dune,
  ocaml,
  version ? if lib.versionAtLeast ocaml.version "4.13" then dune.version else "3.22.2",
}:

buildDunePackage {
  inherit version;
  inherit (dune.override { inherit version; }) src;
  pname = "dune-configurator";
  propagatedBuildInputs = [ csexp ];
  dontAddPrefix = true;

  meta = {
    description = "Helper library for gathering system configuration";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
