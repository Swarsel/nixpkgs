{
  bos,
  buildDunePackage,
  cmdliner,
  cohttp-lwt-unix,
  fmt,
  fpath,
  letsencrypt,
  letsencrypt-dns,
  logs,
  lwt,
  mirage-crypto-rng,
  ptime,
  randomconv,
}:

buildDunePackage {
  inherit (letsencrypt)
    src
    version
    ;

  pname = "letsencrypt-app";

  buildInputs = [
    letsencrypt
    letsencrypt-dns
    cmdliner
    cohttp-lwt-unix
    logs
    fmt
    lwt
    mirage-crypto-rng
    ptime
    bos
    fpath
    randomconv
  ];

  minimalOCamlVersion = "4.08";

  meta = letsencrypt.meta // {
    description = "ACME client implementation of the ACME protocol (RFC 8555) for OCaml";
    mainProgram = "oacmel";
  };
}
