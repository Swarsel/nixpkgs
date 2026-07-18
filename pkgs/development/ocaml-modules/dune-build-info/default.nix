{
  lib,
  buildDunePackage,
  dune-action-plugin,
}:

buildDunePackage {
  inherit (dune-action-plugin) src version;
  pname = "dune-build-info";
  buildInputs = [ dune-action-plugin ];
  dontAddPrefix = true;

  meta = {
    inherit (dune-action-plugin.meta) homepage;
    description = "Embed build information inside executables";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.bcdarwin ];
  };
}
