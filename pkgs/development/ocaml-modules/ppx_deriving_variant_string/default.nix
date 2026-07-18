{
  lib,
  fetchurl,
  buildDunePackage,
  ounit2,
  ppxlib,
}:

buildDunePackage (finalAttrs: {
  pname = "ppx_deriving_variant_string";
  version = "1.1.0";

  src = fetchurl {
    url = "https://github.com/ahrefs/ppx_deriving_variant_string/releases/download/${finalAttrs.version}/ppx_deriving_variant_string-${finalAttrs.version}.tbz";
    hash = "sha256-24m53iwGHbRfTzxiAN055CJ3zLzZ4Syl2Wi28UDlTBQ=";
  };

  propagatedBuildInputs = [
    ppxlib
  ];

  doCheck = true;

  checkInputs = [
    ounit2
  ];

  meta = {
    description = "OCaml PPX deriver that generates converters between regular or polymorphic variants and strings.";
    homepage = "https://github.com/ahrefs/ppx_deriving_variant_string";
    changelog = "https://raw.githubusercontent.com/ahrefs/ppx_deriving_variant_string/${finalAttrs.version}/CHANGES.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.marijanp ];
  };
})
