{
  bigstringaf,
  buildDunePackage,
  ca-certs-nss,
  domain-name,
  fmt,
  git,
  h1,
  ipaddr,
  logs,
  lwt,
  mimic,
  mirage-flow,
  paf,
  rresult,
  tls,
  tls-mirage,
  uri,
}:

buildDunePackage {
  inherit (git) version src;
  pname = "git-paf";

  postPatch = ''
    substituteInPlace src/git-paf/dune --replace-fail bigstringaf 'bigstringaf bstr'
    substituteInPlace src/git-paf/git_paf.ml --replace-fail Bigstringaf.t Bstr.t
  '';

  propagatedBuildInputs = [
    git
    mimic
    paf
    ca-certs-nss
    fmt
    lwt
    rresult
    ipaddr
    logs
    tls
    uri
    bigstringaf
    domain-name
    h1
    mirage-flow
    tls-mirage
  ];

  minimalOCamlVersion = "4.08";

  meta = git.meta // {
    description = "Package to use HTTP-based ocaml-git with MirageOS backend";
  };
}
