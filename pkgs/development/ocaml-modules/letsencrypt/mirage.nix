{
  buildDunePackage,
  emile,
  http-mirage-client,
  letsencrypt,
  paf,
}:

buildDunePackage {
  inherit (letsencrypt) version src;
  pname = "letsencrypt-mirage";

  propagatedBuildInputs = [
    emile
    http-mirage-client
    letsencrypt
    paf
  ];

  meta = letsencrypt.meta // {
    description = "ACME implementation in OCaml for MirageOS";
  };
}
