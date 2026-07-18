{
  lib,
  fetchurl,
  alcotest,
  buildDunePackage,
  pkg-config,
}:

buildDunePackage (finalAttrs: {
  pname = "bigarray-overlap";
  version = "0.2.1";

  src = fetchurl {
    url = "https://github.com/dinosaure/overlap/releases/download/v${finalAttrs.version}/bigarray-overlap-${finalAttrs.version}.tbz";
    hash = "sha256-L1IKxHAFTjNYg+upJUvyi2Z23bV3U8+1iyLPhK4aZuA=";
  };

  nativeBuildInputs = [ pkg-config ];
  doCheck = true;
  checkInputs = [ alcotest ];
  duneVersion = "3";
  minimalOCamlVersion = "4.08";

  meta = {
    description = "Minimal library to know that 2 bigarray share physically the same memory or not";
    homepage = "https://github.com/dinosaure/overlap";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sternenseemann ];
  };
})
