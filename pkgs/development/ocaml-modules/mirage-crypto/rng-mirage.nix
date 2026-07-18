{
  buildDunePackage,
  duration,
  logs,
  lwt,
  mirage-clock-unix,
  mirage-crypto-rng,
  mirage-mtime,
  mirage-runtime,
  mirage-sleep,
  mirage-time-unix,
  mirage-unix,
  ohex,
}:

buildDunePackage {
  inherit (mirage-crypto-rng) version src;
  pname = "mirage-crypto-rng-mirage";

  propagatedBuildInputs = [
    duration
    mirage-crypto-rng
    mirage-runtime
    mirage-mtime
    mirage-sleep
    logs
    lwt
  ];

  doCheck = true;

  checkInputs = [
    mirage-unix
    mirage-clock-unix
    mirage-time-unix
    ohex
  ];

  meta = mirage-crypto-rng.meta // {
    description = "Entropy collection for a cryptographically secure PRNG";
  };
}
