{
  alcotest,
  alcotest-lwt,
  astring,
  base64,
  bigstringaf,
  bos,
  buildDunePackage,
  cacert,
  cmdliner,
  cstruct,
  decompress,
  digestif,
  domain-name,
  fmt,
  fpath,
  git,
  git-binary,
  git-mirage,
  happy-eyeballs-lwt,
  ipaddr,
  ke,
  logs,
  lwt,
  mimic,
  mirage-crypto-rng,
  mirage-flow,
  mtime,
  rresult,
  tcpip,
  tls,
  uri,
}:

buildDunePackage {
  inherit (git) version src;
  pname = "git-unix";

  buildInputs = [
    cmdliner
    tcpip
  ];

  propagatedBuildInputs = [
    rresult
    bigstringaf
    fmt
    bos
    fpath
    digestif
    logs
    lwt
    astring
    decompress
    domain-name
    ipaddr
    mirage-flow
    cstruct
    mimic
    tls
    git
    happy-eyeballs-lwt
    git-mirage
  ];

  doCheck = true;
  nativeCheckInputs = [ git-binary ];

  checkInputs = [
    alcotest
    alcotest-lwt
    base64
    ke
    mirage-crypto-rng
    uri
    mtime
    cacert # sets up NIX_SSL_CERT_FILE
  ];

  minimalOCamlVersion = "4.08";

  meta = {
    inherit (git.meta) homepage license maintainers;
    description = "Unix backend for the Git protocol(s)";
  };
}
