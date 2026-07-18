{
  lib,
  stdenv,
  fetchFromGitHub,
  camlp4,
  findlib,
  fix,
  functory,
  menhir,
  menhirLib,
  ocaml,
  ocamlbuild,
  pprint,
  ulex,
  yojson,
}:

let
  check-ocaml-version = lib.versionAtLeast (lib.getVersion ocaml);
in

assert check-ocaml-version "4";

stdenv.mkDerivation {

  pname = "mezzo";
  version = "0.0.m8";

  src = fetchFromGitHub {
    owner = "protz";
    repo = "mezzo";
    rev = "m8";
    sha256 = "0yck5r6di0935s3iy2mm9538jkf77ssr789qb06ms7sivd7g3ip6";
  };

  strictDeps = true;

  nativeBuildInputs = [
    ocaml
    findlib
    ocamlbuild
    camlp4
    menhir
  ];

  buildInputs = [
    yojson
    menhirLib
    ulex
    pprint
    fix
    functory
    ocamlbuild
  ];

  postInstall = ''
    mkdir $out/bin
    cp mezzo $out/bin/
  '';

  createFindlibDestdir = true;

  # Sets warning 3 as non-fatal
  prePatch =
    lib.optionalString (check-ocaml-version "4.02") ''
      substituteInPlace myocamlbuild.pre.ml \
      --replace '@1..3' '@1..2+3'
    ''
    # Compatibility with PPrint ≥ 20220103
    + ''
      substituteInPlace typing/Fact.ml --replace PPrintOCaml PPrint.OCaml
    '';

  meta = {
    description = "Programming language in the ML tradition, which places strong emphasis on the control of aliasing and access to mutable memory";
    homepage = "http://protz.github.io/mezzo/";
    license = lib.licenses.gpl2;
    platforms = ocaml.meta.platforms or [ ];
    broken = lib.versionAtLeast ocaml.version "4.06";
  };
}
