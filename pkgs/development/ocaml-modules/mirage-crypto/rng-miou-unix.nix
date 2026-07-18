{
  buildDunePackage,
  digestif,
  duration,
  logs,
  miou,
  mirage-crypto-rng,
  mtime,
  ohex,
}:

buildDunePackage {
  inherit (mirage-crypto-rng) version src;
  pname = "mirage-crypto-rng-miou-unix";

  propagatedBuildInputs = [
    miou
    logs
    mirage-crypto-rng
    duration
    mtime
    digestif
    ohex
  ];

  doCheck = true;

  checkInputs = [

  ];

  meta = mirage-crypto-rng.meta // {
    description = "Feed the entropy source in an miou.unix-friendly way";

    longDescription = ''
      Mirage-crypto-rng-miou-unix feeds the entropy source for Mirage_crypto_rng-based
      random number generator implementations, in an miou.unix-friendly way.
    '';
  };
}
