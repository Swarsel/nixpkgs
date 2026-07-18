{
  lib,
  stdenv,
  fetchurl,
  alcotest,
  alcotest-lwt,
  angstrom,
  astring,
  base64,
  bigstringaf,
  buildDunePackage,
  carton,
  carton-git,
  carton-lwt,
  checkseum,
  cmdliner,
  crowbar,
  decompress,
  digestif,
  domain-name,
  emile,
  encore,
  fmt,
  git-binary,
  hxd,
  ipaddr,
  ke,
  logs,
  lwt,
  mimic,
  mirage-crypto-rng,
  mirage-flow,
  ocamlgraph,
  optint,
  psq,
  rresult,
  uri,
}:

buildDunePackage (finalAttrs: {
  pname = "git";
  version = "3.18.0";

  src = fetchurl {
    url = "https://github.com/mirage/ocaml-git/releases/download/${finalAttrs.version}/git-${finalAttrs.version}.tbz";
    hash = "sha256-kleVYn5tquC0vRaqUGh53xHLIB5l/v446BN48Y1RfUs=";
  };

  buildInputs = [
    base64
  ];

  propagatedBuildInputs = [
    angstrom
    astring
    checkseum
    decompress
    digestif
    encore
    fmt
    ke
    logs
    lwt
    ocamlgraph
    uri
    rresult
    bigstringaf
    optint
    mirage-flow
    domain-name
    emile
    mimic
    carton
    carton-lwt
    carton-git
    ipaddr
    psq
    hxd
  ];

  doCheck = !stdenv.hostPlatform.isAarch64;

  nativeCheckInputs = [
    git-binary
  ];

  checkInputs = [
    alcotest
    alcotest-lwt
    mirage-crypto-rng
    crowbar
    cmdliner
  ];

  minimalOCamlVersion = "4.08";

  meta = {
    description = "Git format and protocol in pure OCaml";
    homepage = "https://github.com/mirage/ocaml-git";
    license = lib.licenses.isc;

    maintainers = with lib.maintainers; [
      sternenseemann
      vbgl
    ];
  };
})
