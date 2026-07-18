{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  fetchpatch,
  ocaml,
  ounit,
  ounit2,
  ppx_deriving,
  ppxlib,
  result,
  yojson,
}:

let
  param =
    if lib.versionAtLeast ppxlib.version "0.36" then
      {
        version = "3.10.0";
        checkInputs = [ ounit2 ];
        sha256 = "sha256-Dy9egNpZdxsTPLo2mbpiFTMh5cYUXXOlOZLlQJuAK+E=";
      }
    else if lib.versionAtLeast ppxlib.version "0.30" then
      {
        version = "3.9.0";
        checkInputs = [ ounit2 ];
        sha256 = "sha256-0d6YcBkeFoHXffCYjLIIvruw8B9ZB6NbUijhTv9uyN8=";
      }
    else
      {
        version = "3.6.1";
        propagatedBuildInputs = [ result ];
        checkInputs = [ ounit ];
        sha256 = "1icz5h6p3pfj7my5gi7wxpflrb8c902dqa17f9w424njilnpyrbk";
      };
in

buildDunePackage (finalAttrs: {
  inherit (param) version;
  inherit (param) checkInputs;
  pname = "ppx_deriving_yojson";

  src = fetchFromGitHub {
    inherit (param) sha256;
    owner = "ocaml-ppx";
    repo = "ppx_deriving_yojson";
    rev = "v${finalAttrs.version}";
  };

  patches = fetchpatch {
    hash = "sha256-jYW2/Ix6T94vfI2mGnIkYSG1rjsWEsnOPA1mufP3sd4=";
    url = "https://github.com/ocaml-ppx/ppx_deriving_yojson/commit/1bbbe2c4c5822c4297b0b812c59a155cf96c5089.patch";
  };

  propagatedBuildInputs = [
    ppxlib
    ppx_deriving
    yojson
  ]
  ++ param.propagatedBuildInputs or [ ];

  doCheck = true;

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "Yojson codec generator for OCaml >= 4.04";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.vbgl ];
  };
})
