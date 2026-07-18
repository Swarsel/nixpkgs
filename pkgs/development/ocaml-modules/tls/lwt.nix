{
  buildDunePackage,
  lwt,
  mirage-crypto-rng,
  tls,
}:

buildDunePackage {
  inherit (tls) src meta version;
  pname = "tls-lwt";

  propagatedBuildInputs = [
    lwt
    mirage-crypto-rng
    tls
  ];

  doCheck = true;
  minimalOCamlVersion = "4.11";
}
