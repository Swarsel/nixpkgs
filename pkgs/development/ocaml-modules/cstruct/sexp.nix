{
  lib,
  alcotest,
  buildDunePackage,
  cstruct,
  ocaml,
  sexplib,
}:

if lib.versionOlder (cstruct.version or "1") "3" then
  cstruct
else

  buildDunePackage {
    inherit (cstruct) version src meta;
    pname = "cstruct-sexp";

    propagatedBuildInputs = [
      cstruct
      sexplib
    ];

    doCheck = true;
    checkInputs = [ alcotest ];
    duneVersion = "3";
    minimalOCamlVersion = "4.08";
  }
