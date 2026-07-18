{
  async,
  buildDunePackage,
  core,
  cstruct-async,
  mirage-crypto-rng,
  tls,
}:

buildDunePackage {
  inherit (tls) src version;
  pname = "tls-async";

  propagatedBuildInputs = [
    async
    core
    cstruct-async
    mirage-crypto-rng
    tls
  ];

  doCheck = true;
  minimalOCamlVersion = "4.14";

  meta = tls.meta // {
    description = "Transport Layer Security purely in OCaml, Async layer";
  };
}
