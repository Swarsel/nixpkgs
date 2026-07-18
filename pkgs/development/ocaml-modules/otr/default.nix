{
  lib,
  fetchurl,
  astring,
  base64,
  buildDunePackage,
  digestif,
  mirage-crypto,
  mirage-crypto-pk,
  sexplib0,
}:

buildDunePackage (finalAttrs: {
  pname = "otr";
  version = "1.0.0";

  src = fetchurl {
    url = "https://github.com/hannesm/ocaml-otr/releases/download/v${finalAttrs.version}/otr-${finalAttrs.version}.tbz";
    hash = "sha256-/CcVqLbdylB+LqpKNETkpvQ8SEAIcEFCO1MZqvdmJWU=";
  };

  propagatedBuildInputs = [
    digestif
    sexplib0
    mirage-crypto
    mirage-crypto-pk
    astring
    base64
  ];

  doCheck = true;
  minimalOCamlVersion = "4.13";

  meta = {
    description = "Off-the-record messaging protocol, purely in OCaml";
    homepage = "https://github.com/hannesm/ocaml-otr";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ sternenseemann ];
  };
})
