{
  lib,
  stdenv,
  fetchFromGitHub,
  findlib,
  ocaml,
  ocamlbuild,
}:

stdenv.mkDerivation rec {
  pname = "ocaml-iso8601";
  version = "0.2.5";

  src = fetchFromGitHub {
    owner = "sagotch";
    repo = "ISO8601.ml";
    rev = version;
    sha256 = "sha256-QWjZ+2AjvXnnRVenbyCG/hSjfW53bHiftQUtWpK/7I8=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    ocaml
    findlib
    ocamlbuild
  ];

  createFindlibDestdir = true;

  meta = {
    description = "ISO 8601 and RFC 3999 date parsing for OCaml";
    homepage = "https://ocaml-community.github.io/ISO8601.ml/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ vbgl ];
    platforms = ocaml.meta.platforms or [ ];
  };
}
