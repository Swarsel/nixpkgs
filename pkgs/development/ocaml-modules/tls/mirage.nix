{
  buildDunePackage,
  fmt,
  lwt,
  mirage-crypto,
  mirage-crypto-pk,
  mirage-flow,
  mirage-kv,
  mirage-ptime,
  ptime,
  tls,
}:

buildDunePackage {
  inherit (tls) src version;
  pname = "tls-mirage";

  propagatedBuildInputs = [
    fmt
    lwt
    mirage-crypto
    mirage-crypto-pk
    mirage-flow
    mirage-kv
    mirage-ptime
    ptime
    tls
  ];

  meta = tls.meta // {
    description = "Transport Layer Security purely in OCaml, MirageOS layer";
  };
}
