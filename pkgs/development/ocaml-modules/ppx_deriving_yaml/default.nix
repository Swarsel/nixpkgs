{
  lib,
  fetchurl,
  alcotest,
  buildDunePackage,
  mdx,
  ocaml,
  ppx_deriving,
  ppxlib,
  yaml,
}:

let
  param =
    if lib.versionAtLeast ppxlib.version "0.36" then
      {
        version = "0.4.1";
        hash = "sha256-3CvvMEOq/3I3WJ6X5EyopiaMjshZoEMPk2K4Lx0ldSo=";
      }
    else
      {
        version = "0.4.0";
        hash = "sha256-MVwCFAZY9Ui1gOckfbbj882w2aloHCGmJhpL1BDUEAg=";
      };
in

buildDunePackage (finalAttrs: {
  inherit (param) version;
  pname = "ppx_deriving_yaml";

  src = fetchurl {
    inherit (param) hash;
    url = "https://github.com/patricoferris/ppx_deriving_yaml/releases/download/v${finalAttrs.version}/ppx_deriving_yaml-${finalAttrs.version}.tbz";
  };

  propagatedBuildInputs = [
    ppxlib
    ppx_deriving
    yaml
  ];

  env =
    # Fix build with gcc15
    lib.optionalAttrs
      (lib.versions.majorMinor ocaml.version == "4.13" || lib.versions.majorMinor ocaml.version == "5.0")
      {
        NIX_CFLAGS_COMPILE = "-std=gnu11";
      };

  doCheck = true;
  nativeCheckInputs = [ mdx.bin ];

  checkInputs = [
    alcotest
    mdx
  ];

  meta = {
    description = "YAML codec generator for OCaml";
    homepage = "https://github.com/patricoferris/ppx_deriving_yaml";
    license = lib.licenses.isc;
    maintainers = [ ];
  };
})
