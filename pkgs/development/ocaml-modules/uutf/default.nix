{
  lib,
  stdenv,
  fetchurl,
  cmdliner,
  findlib,
  ocaml,
  ocamlbuild,
  topkg,
  uchar,
  version ?
    if lib.versionAtLeast ocaml.version "4.08" then
      "1.0.4"
    else if lib.versionAtLeast ocaml.version "4.03" then
      "1.0.3"
    else
      throw "uutf is not available with OCaml ${ocaml.version}",
}:

stdenv.mkDerivation (finalAttrs: {
  inherit version;
  inherit (topkg) buildPhase installPhase;
  pname = "uutf";

  src = fetchurl {
    url = "https://erratique.ch/software/uutf/releases/uutf-${version}.tbz";

    hash =
      {
        "1.0.3" = "sha256-h3KlYT0ecCmM4U3zMkGjaF8h5O9r20zwP+mF+x7KBWg=";
        "1.0.4" = "sha256-p6V45q+RSaiJThjjtHWchWWTemnGyaznowu/BIRhnKg=";
      }
      ."${version}";
  };

  strictDeps = true;

  nativeBuildInputs = [
    ocaml
    ocamlbuild
    findlib
    topkg
  ];

  buildInputs = [
    topkg
    cmdliner
  ];

  propagatedBuildInputs = [ uchar ];
  name = "ocaml${ocaml.version}-${finalAttrs.pname}-${finalAttrs.version}";

  meta = {
    inherit (ocaml.meta) platforms;
    description = "Non-blocking streaming Unicode codec for OCaml";
    homepage = "https://erratique.ch/software/uutf";
    changelog = "https://raw.githubusercontent.com/dbuenzli/uutf/refs/tags/v${version}/CHANGES.md";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.vbgl ];
    mainProgram = "utftrip";
  };
})
