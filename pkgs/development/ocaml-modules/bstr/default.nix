{
  lib,
  fetchurl,
  buildDunePackage,
}:

buildDunePackage (finalAttrs: {
  pname = "bstr";
  version = "0.0.2";

  src = fetchurl {
    url = "https://github.com/robur-coop/bstr/releases/download/v${finalAttrs.version}/bstr-${finalAttrs.version}.tbz";
    hash = "sha256-/zvzCBzT014OesTmxGBDB98ZRU++YNDLUZ8uaDK3keM=";
  };

  minimalOCamlVersion = "4.13";

  meta = {
    description = "A simple library for bigstrings";
    homepage = "https://git.robur.coop/robur/bstr";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.vbgl ];
  };
})
