{
  lib,
  stdenv,
  fetchFromGitHub,
  camlp4,
  findlib,
  ocaml,
  ocamlbuild,
}:

let
  pname = "ulex";
  param =
    if lib.versionAtLeast ocaml.version "4.02" then
      {
        version = "1.2";
        sha256 = "08yf2x9a52l2y4savjqfjd2xy4pjd1rpla2ylrr9qrz1drpfw4ic";
      }
    else
      {
        version = "1.1";
        sha256 = "0cmscxcmcxhlshh4jd0lzw5ffzns12x3bj7h27smbc8waxkwffhl";
      };
in
stdenv.mkDerivation {
  inherit (param) version;
  pname = "ocaml${ocaml.version}-${pname}";

  src = fetchFromGitHub {
    inherit (param) sha256;
    owner = "ocaml-community";
    repo = pname;
    rev = "v${param.version}";
  };

  strictDeps = true;

  nativeBuildInputs = [
    ocaml
    findlib
    ocamlbuild
    camlp4
  ];

  propagatedBuildInputs = [ camlp4 ];

  buildFlags = [
    "all"
    "all.opt"
  ];

  createFindlibDestdir = true;

  meta = {
    inherit (ocaml.meta) platforms;
    description = "Lexer generator for Unicode and OCaml";
    homepage = "https://opam.ocaml.org/packages/ulex/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.roconnor ];
    broken = lib.versionAtLeast ocaml.version "5.0";
  };
}
