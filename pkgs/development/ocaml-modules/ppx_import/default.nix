{
  lib,
  fetchurl,
  buildDunePackage,
  ocaml,
  ounit,
  ppx_deriving,
  ppx_sexp_conv,
  ppxlib,
  version ?
    if lib.versionAtLeast ppxlib.version "0.36" then
      "1.12.0"
    else if lib.versionAtLeast ppxlib.version "0.26" then
      "1.11.0"
    else if lib.versionAtLeast ppxlib.version "0.24.0" then
      "1.9.1"
    else
      throw "ppx_import is not available with ppxlib-${ppxlib.version}",
}:

buildDunePackage {
  inherit version;
  pname = "ppx_import";

  src = fetchurl {
    url =
      let
        dir = if lib.versionAtLeast version "1.11" then "v${version}" else "${version}";
      in
      "https://github.com/ocaml-ppx/ppx_import/releases/download/${dir}/ppx_import-${version}.tbz";

    hash =
      {
        "1.11.0" = "sha256-Jmfv1IkQoaTkyxoxp9FI0ChNESqCaoDsA7D4ZUbOrBo=";
        "1.12.0" = "sha256-1vpYHFl0rEdG3hE+6BCpWmfLvdLvoEx+Jxq0DFrRdJc=";
        "1.9.1" = "sha256-0bSY4u44Ds84XPIbcT5Vt4AG/4PkzFKMl9CDGFZyIdI=";
      }
      ."${version}";
  };

  propagatedBuildInputs = [
    ppxlib
  ];

  doCheck = true;

  checkInputs = [
    ounit
    ppx_deriving
    ppx_sexp_conv
  ];

  meta = {
    description = "Syntax extension for importing declarations from interface files";
    homepage = "https://github.com/ocaml-ppx/ppx_import";
    license = lib.licenses.mit;
    broken = lib.versionAtLeast ocaml.version "5.5";
  };
}
