{
  lib,
  stdenv,
  fetchFromGitHub,
  findlib,
  ocaml,
  ocamlbuild,
}:

stdenv.mkDerivation {
  pname = "ocaml${ocaml.version}-erm_xml";
  version = "0.3+20180112";

  src = fetchFromGitHub {
    owner = "hannesm";
    repo = "xml";
    rev = "bbabdade807d8281fc48806da054b70dfe482479";
    sha256 = "sha256-OQdLTq9tJZc6XlcuPv2gxzYiQAUGd6AiBzfSi169XL0=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    ocaml
    findlib
    ocamlbuild
  ];

  createFindlibDestdir = true;

  meta = {
    description = "XML Parser for discrete data";
    homepage = "https://github.com/hannesm/xml";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ vbgl ];
    platforms = ocaml.meta.platforms or [ ];
    broken = lib.versionOlder ocaml.version "4.02" || lib.versionAtLeast ocaml.version "5.0";
  };
}
