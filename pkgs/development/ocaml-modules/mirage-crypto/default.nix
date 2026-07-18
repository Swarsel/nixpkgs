{
  lib,
  fetchurl,
  buildDunePackage,
  dune-configurator,
  eqaf,
  ohex,
  ounit2,
}:

buildDunePackage (finalAttrs: {
  pname = "mirage-crypto";
  version = "2.1.0";

  src = fetchurl {
    url = "https://github.com/mirage/mirage-crypto/releases/download/v${finalAttrs.version}/mirage-crypto-${finalAttrs.version}.tbz";
    hash = "sha256-++2omj17+pmS/b7z67/HKA/O/dQloEBeMzBRJc1AmBU=";
  };

  buildInputs = [ dune-configurator ];

  propagatedBuildInputs = [
    eqaf
  ];

  doCheck = true;

  checkInputs = [
    ohex
    ounit2
  ];

  minimalOCamlVersion = "4.13";

  meta = {
    description = "Simple symmetric cryptography for the modern age";
    homepage = "https://github.com/mirage/mirage-crypto";
    changelog = "https://raw.githubusercontent.com/mirage/mirage-crypto/refs/tags/v${finalAttrs.version}/CHANGES.md";

    license = with lib.licenses; [
      isc # default license
      bsd2 # mirage-crypto-rng-mirage
      mit # mirage-crypto-ec
    ];

    maintainers = with lib.maintainers; [
      sternenseemann
    ];
  };
})
