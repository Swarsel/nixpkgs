{
  alcotest,
  alcotest-lwt,
  awa,
  awa-mirage,
  base64,
  bigstringaf,
  buildDunePackage,
  ca-certs-nss,
  cstruct,
  domain-name,
  fmt,
  git,
  git-paf,
  happy-eyeballs,
  happy-eyeballs-mirage,
  ipaddr,
  ke,
  logs,
  lwt,
  mimic,
  mimic-happy-eyeballs,
  mirage-crypto,
  mirage-flow,
  mirage-ptime,
  mirage-sleep,
  ptime,
  tcpip,
  tls,
  tls-mirage,
  uri,
  x509,
}:

buildDunePackage {
  inherit (git) version src;
  pname = "git-mirage";

  buildInputs = [
    happy-eyeballs-mirage
    ipaddr
  ];

  propagatedBuildInputs = [
    git
    mimic
    mimic-happy-eyeballs
    base64
    git-paf
    awa
    awa-mirage
    tls
    tls-mirage
    uri
    happy-eyeballs
    ca-certs-nss
    mirage-crypto
    ptime
    x509
    cstruct
    tcpip
    domain-name
    fmt
    lwt
    mirage-ptime
    mirage-flow
    mirage-sleep
  ];

  checkInputs = [
    alcotest
    alcotest-lwt
    bigstringaf
    logs
    ke
  ];

  minimalOCamlVersion = "4.08";

  meta = git.meta // {
    description = "Package to use ocaml-git with MirageOS backend";
  };
}
