{
  lib,
  buildDunePackage,
  csexp,
  findlib,
  merlin,
  merlin-lib,
  result,
  yojson,
}:

buildDunePackage rec {
  inherit (merlin) version src;
  pname = "dot-merlin-reader";

  buildInputs = [
    findlib
  ]
  ++ (
    if lib.versionAtLeast version "4.7-414" then
      [ merlin-lib ]
    else
      [
        yojson
        csexp
        result
      ]
  );

  minimalOCamlVersion = "4.06";

  meta = {
    description = "Reads config files for merlin";
    homepage = "https://github.com/ocaml/merlin";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.hongchangwu ];
    mainProgram = "dot-merlin-reader";
  };
}
