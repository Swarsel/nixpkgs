{
  buildDunePackage,
  gmp,
  mirage-crypto,
  mirage-crypto-rng,
  ohex,
  ounit2,
  randomconv,
  zarith,
}:

buildDunePackage {
  inherit (mirage-crypto) version src;
  pname = "mirage-crypto-pk";
  buildInputs = [ gmp ];

  propagatedBuildInputs = [
    mirage-crypto
    mirage-crypto-rng
    zarith
  ];

  doCheck = true;

  checkInputs = [
    ohex
    ounit2
    randomconv
  ];

  meta = mirage-crypto.meta // {
    description = "Simple public-key cryptography for the modern age";
  };
}
