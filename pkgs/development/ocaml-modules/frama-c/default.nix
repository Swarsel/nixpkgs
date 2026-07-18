{
  stdenv,
  camlzip,
  dune-site,
  findlib,
  frama-c,
  menhirLib,
  ocaml,
  ocamlgraph,
  pkgs,
  ppx_deriving,
  ppx_inline_test,
  yaml,
  yojson,
  zarith,
  zmq,
}:

stdenv.mkDerivation {
  inherit (frama-c) version meta;
  pname = "ocaml${ocaml.version}-frama-c";
  buildInputs = [ findlib ];

  propagatedBuildInputs = [
    camlzip
    dune-site
    menhirLib
    ocamlgraph
    ppx_deriving
    ppx_inline_test
    yaml
    yojson
    zarith
    zmq
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $OCAMLFIND_DESTDIR
    for p in ${frama-c}/lib/*
    do
      ln -s $p $OCAMLFIND_DESTDIR/
    done
    runHook postInstall
  '';

  dontUnpack = true;
}
