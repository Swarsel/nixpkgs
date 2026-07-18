{
  lib,
  fetchurl,
  angstrom-unix,
  binning,
  buildDunePackage,
  camlzip,
  core_kernel,
  fmt,
  gsl,
  ocaml-crunch,
  ppx_deriving,
  rresult,
  tyxml,
  uri,
  vg,
  core_unix ? null,
  csvfields ? null,
  ppx_csv_conv ? null,
}:

buildDunePackage (finalAttrs: {
  pname = "biotk";
  version = "0.3";

  src = fetchurl {
    url = "https://github.com/pveber/biotk/releases/download/v${finalAttrs.version}/biotk-${finalAttrs.version}.tbz";
    hash = "sha256-9eRd3qYteUxu/xNEUER/DHodr6cTCuPtSKr38x32gig=";
  };

  nativeBuildInputs = [ ocaml-crunch ];
  buildInputs = [ ppx_csv_conv ];

  propagatedBuildInputs = [
    angstrom-unix
    binning
    camlzip
    core_kernel
    core_unix
    csvfields
    fmt
    gsl
    ppx_deriving
    rresult
    tyxml
    uri
    vg
  ];

  minimalOCamlVersion = "4.13";

  meta = {
    description = "Toolkit for bioinformatics in OCaml";
    license = lib.licenses.cecill-c;
  };
})
