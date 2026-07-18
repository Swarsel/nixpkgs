{
  lib,
  atd,
  buildDunePackage,
  cmdliner,
}:

buildDunePackage {
  inherit (atd) version src;
  pname = "atdml";
  buildInputs = [ cmdliner ];
  propagatedBuildInputs = [ atd ];
  minimalOCamlVersion = "4.10";

  meta = atd.meta // {
    description = "Simplified OCaml JSON serializers using the Yojson AST";
    maintainers = [ lib.maintainers.vbgl ];
    mainProgram = "atdml";
  };
}
