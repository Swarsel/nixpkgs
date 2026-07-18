{
  lib,
  buildDunePackage,
  cppo,
  ocamlbuild,
}:

if lib.versionOlder (lib.getVersion cppo) "1.6" then
  cppo
else

  buildDunePackage {
    inherit (cppo) version src;
    pname = "cppo_ocamlbuild";
    propagatedBuildInputs = [ ocamlbuild ];
    duneVersion = "3";
    minimalOCamlVersion = "4.03";

    meta = cppo.meta // {
      description = "Plugin to use cppo with ocamlbuild";
    };
  }
