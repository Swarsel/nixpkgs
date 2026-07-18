{
  lib,
  fetchFromGitHub,
  base,
  buildDunePackage,
  dune-configurator,
  fetchpatch,
  secp256k1,
  stdio,
}:

buildDunePackage (finalAttrs: {
  pname = "secp256k1";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "dakk";
    repo = "secp256k1-ml";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PD+4+OE0ttQsyG+i5Ez9kdo1A2DPNxvUjRQHXXSxaKo=";
  };

  buildInputs = [
    base
    stdio
    dune-configurator
    secp256k1
  ];

  minimalOCamlVersion = "4.12";

  meta = {
    description = "Elliptic curve library secp256k1 wrapper for Ocaml";
    homepage = "https://github.com/dakk/secp256k1-ml";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.vyorkin ];
  };
})
