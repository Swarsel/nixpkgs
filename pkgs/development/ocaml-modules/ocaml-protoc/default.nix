{
  lib,
  buildDunePackage,
  ocaml,
  pbrt,
  pbrt_services,
  stdlib-shims,
}:

buildDunePackage {
  inherit (pbrt) version src;
  pname = "ocaml-protoc";
  buildInputs = [ stdlib-shims ];
  propagatedBuildInputs = [ pbrt ];
  doCheck = lib.versionAtLeast ocaml.version "5.1";
  checkInputs = [ pbrt_services ];

  meta = pbrt.meta // {
    description = "Protobuf Compiler for OCaml";
  };
}
