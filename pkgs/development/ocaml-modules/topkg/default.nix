/*
  Topkg is a packager for distributing OCaml software. This derivation
  provides facilities to describe derivations for OCaml libraries
  using topkg.
  The `buildPhase` and `installPhase` attributes can be reused directly
  in many cases. When more fine-grained control on how to run the “topkg”
  build system is required, the attribute `run` can be used.
*/
{
  lib,
  stdenv,
  fetchurl,
  findlib,
  ocaml,
  ocamlbuild,
  opaline,
  result,
}:

let
  param =
    if lib.versionAtLeast ocaml.version "4.05" then
      {
        version = "1.1.0";
        hash = "sha256-rS2n9eoqRKclaOy5W1ezaquItfnhH/ee+2TkFvF3FOA=";
      }
    else if lib.versionAtLeast ocaml.version "4.03" then
      {
        version = "1.0.3";
        hash = "sha256:0b77gsz9bqby8v77kfi4lans47x9p2lmzanzwins5r29maphb8y6";
      }
    else
      {
        version = "1.0.0";
        propagatedBuildInputs = [ result ];
        hash = "sha256:1df61vw6v5bg2mys045682ggv058yqkqb67w7r2gz85crs04d5fw";
      };

  /*
    This command allows to run the “topkg” build system.
    It is usually called with `build` or `test` as argument.
    Packages that use `topkg` may call this command as part of
     their `buildPhase` or `checkPhase`.
  */
  run = "ocaml -I ${findlib}/lib/ocaml/${ocaml.version}/site-lib/ pkg/pkg.ml";
in

stdenv.mkDerivation rec {
  inherit (param) version;
  pname = "ocaml${ocaml.version}-topkg";

  src = fetchurl {
    inherit (param) hash;
    url = "https://erratique.ch/software/topkg/releases/topkg-${version}.tbz";
  };

  strictDeps = true;

  nativeBuildInputs = [
    ocaml
    findlib
    ocamlbuild
  ];

  propagatedBuildInputs = param.propagatedBuildInputs or [ ];
  buildPhase = "${run} build";
  installPhase = "${opaline}/bin/opaline -prefix $out -libdir $OCAMLFIND_DESTDIR";
  createFindlibDestdir = true;
  passthru = { inherit run; };

  meta = {
    inherit (ocaml.meta) platforms;
    description = "Packager for distributing OCaml software";
    homepage = "https://erratique.ch/software/topkg";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.vbgl ];
  };
}
