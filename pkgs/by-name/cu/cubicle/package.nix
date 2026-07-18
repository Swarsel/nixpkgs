{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  ocaml-ng,
  which,
}:

let
  ocamlPackages = ocaml-ng.ocamlPackages_4_14;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "cubicle";
  version = "1.2.0";

  src = fetchurl {
    url = "https://github.com/cubicle-model-checker/cubicle/archive/refs/tags/${finalAttrs.version}.tar.gz";
    hash = "sha256-/EtbXpyXqRm0jGcMfGLAEwdr92061edjFys1V7/w6/Y=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    which
  ]
  ++ (with ocamlPackages; [
    findlib
    ocaml
  ]);

  buildInputs = with ocamlPackages; [
    functory
    num
  ];

  # https://github.com/cubicle-model-checker/cubicle/issues/1
  env = {
    OCAMLC = "ocamlfind ocamlc -package num";
    OCAMLOPT = "ocamlfind ocamlopt -package num";
  };

  meta = {
    description = "Open source model checker for verifying safety properties of array-based systems";
    homepage = "https://cubicle.lri.fr/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dwarfmaster ];
    platforms = lib.platforms.unix;
    mainProgram = "cubicle";
  };
})
