{ stdenv, ocamlPackages }:

let
  inherit (ocamlPackages) ocaml findlib sawja;
in

stdenv.mkDerivation {

  inherit (sawja) src version;
  pname = "sawjap";
  strictDeps = true;

  nativeBuildInputs = [
    ocaml
    findlib
  ];

  buildInputs = [ sawja ];

  buildPhase = ''
    runHook preBuild
    mkdir -p $out/bin
    ocamlfind opt -o $out/bin/sawjap -package sawja -linkpkg sawjap.ml
    runHook postBuild
  '';

  dontInstall = true;
  prePatch = "cd test";

  meta = sawja.meta // {
    description = "Pretty-print .class files";
    mainProgram = "sawjap";
  };

}
