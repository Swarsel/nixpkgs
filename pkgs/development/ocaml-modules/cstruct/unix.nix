{
  lib,
  buildDunePackage,
  cstruct,
}:

if lib.versionOlder (cstruct.version or "1") "3" then
  cstruct
else

  buildDunePackage {
    inherit (cstruct) version src meta;
    pname = "cstruct-unix";
    propagatedBuildInputs = [ cstruct ];
    duneVersion = "3";
    minimalOCamlVersion = "4.08";
  }
