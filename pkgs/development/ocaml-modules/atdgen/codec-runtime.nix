{
  lib,
  fetchurl,
  buildDunePackage,
}:

buildDunePackage (finalAttrs: {
  pname = "atdgen-codec-runtime";
  version = "4.2.0";

  src = fetchurl {
    url = "https://github.com/ahrefs/atd/releases/download/${finalAttrs.version}/atd-${finalAttrs.version}.tbz";
    hash = "sha256-QOVMjs3EV5QVUiH0KZwqnUkXD07EFCToyInSNaUtOlU=";
  };

  meta = {
    description = "Runtime for atdgen generated bucklescript converters";
    homepage = "https://github.com/ahrefs/atd";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.vbgl ];
  };
})
