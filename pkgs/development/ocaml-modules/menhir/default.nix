{
  buildDunePackage,
  menhirGLR,
  menhirLib,
  menhirSdk,
  ocaml,
  replaceVars,
}:

buildDunePackage {
  inherit (menhirLib) version src;
  pname = "menhir";

  patches = [
    (replaceVars ./menhir-suggest-menhirLib.patch {
      libdir = "${menhirLib}/lib/ocaml/${ocaml.version}/site-lib/menhirLib";
    })
  ];

  buildInputs = [
    menhirGLR
    menhirLib
    menhirSdk
  ];

  meta = menhirSdk.meta // {
    description = "LR(1) parser generator for OCaml";
    mainProgram = "menhir";
  };
}
