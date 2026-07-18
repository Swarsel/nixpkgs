{
  atd,
  buildDunePackage,
  re,
}:

buildDunePackage {
  inherit (atd) src version;
  pname = "atd-jsonlike";
  propagatedBuildInputs = [ re ];
  minimalOCamlVersion = "4.12";

  meta = (removeAttrs atd.meta [ "mainProgram" ]) // {
    description = "Generic JSON-like AST for use with ATD code generators";
  };
}
