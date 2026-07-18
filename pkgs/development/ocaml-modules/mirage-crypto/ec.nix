{
  alcotest,
  asn1-combinators,
  buildDunePackage,
  dune-configurator,
  mirage-crypto,
  mirage-crypto-rng,
  ohex,
  ounit2,
  pkg-config,
  ppx_deriving,
  ppx_deriving_yojson,
  yojson,
}:

buildDunePackage {
  inherit (mirage-crypto)
    src
    version
    ;

  pname = "mirage-crypto-ec";
  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    dune-configurator
  ];

  propagatedBuildInputs = [
    mirage-crypto
    mirage-crypto-rng
  ];

  doCheck = true;

  checkInputs = [
    alcotest
    asn1-combinators
    ohex
    ounit2
    ppx_deriving_yojson
    ppx_deriving
    yojson
  ];

  meta = mirage-crypto.meta // {
    description = "Elliptic Curve Cryptography with primitives taken from Fiat";
  };
}
