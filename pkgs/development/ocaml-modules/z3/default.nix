{
  lib,
  stdenv,
  findlib,
  ocaml,
  z3,
  zarith,
}:

let
  z3-with-ocaml = (
    z3.override {
      inherit ocaml findlib zarith;
      ocamlBindings = true;
    }
  );
in

stdenv.mkDerivation {

  inherit (z3-with-ocaml) version;
  pname = "ocaml${ocaml.version}-z3";
  strictDeps = true;
  nativeBuildInputs = [ findlib ];

  propagatedBuildInputs = [
    z3-with-ocaml.lib
    zarith
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $OCAMLFIND_DESTDIR
    cp -r ${z3-with-ocaml.ocaml}/lib/ocaml/${ocaml.version}/site-lib/stublibs $OCAMLFIND_DESTDIR
    cp -r ${z3-with-ocaml.ocaml}/lib/ocaml/${ocaml.version}/site-lib/Z3 $OCAMLFIND_DESTDIR/z3
    runHook postInstall
  '';

  dontUnpack = true;

  meta = z3.meta // {
    description = "Z3 Theorem Prover (OCaml API)";
    broken = lib.versionOlder ocaml.version "4.08";
  };
}
