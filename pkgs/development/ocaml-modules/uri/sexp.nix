{
  lib,
  buildDunePackage,
  ocaml,
  ounit,
  ppx_sexp_conv,
  sexplib0,
  uri,
}:

buildDunePackage {
  inherit (uri) version src;
  pname = "uri-sexp";

  propagatedBuildInputs = [
    ppx_sexp_conv
    sexplib0
    uri
  ];

  doCheck = lib.versionAtLeast ocaml.version "4.08";
  checkInputs = [ ounit ];
  duneVersion = "3";

  meta = uri.meta // {
    broken = uri.meta.broken or false || lib.versionOlder ocaml.version "4.04";
  };
}
