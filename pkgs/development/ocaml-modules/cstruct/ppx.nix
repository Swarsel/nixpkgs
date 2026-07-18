{
  lib,
  buildDunePackage,
  cppo,
  cstruct,
  cstruct-sexp,
  cstruct-unix,
  ocaml,
  ocaml-migrate-parsetree-2,
  ounit,
  ppx_sexp_conv,
  ppxlib,
  sexplib,
}:

if lib.versionOlder (cstruct.version or "1") "3" then
  cstruct
else

  buildDunePackage {
    inherit (cstruct) version src meta;
    pname = "ppx_cstruct";

    propagatedBuildInputs = [
      cstruct
      ppxlib
      sexplib
    ];

    doCheck = !lib.versionAtLeast ocaml.version "5.1";
    nativeCheckInputs = [ cppo ];

    checkInputs = [
      ounit
      ppx_sexp_conv
      cstruct-sexp
      cstruct-unix
      ocaml-migrate-parsetree-2
    ];

    minimalOCamlVersion = "4.08";
  }
