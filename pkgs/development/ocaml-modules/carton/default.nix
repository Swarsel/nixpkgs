{
  lib,
  fetchurl,
  alcotest,
  alcotest-lwt,
  base64,
  bigstringaf,
  bos,
  buildDunePackage,
  checkseum,
  cmdliner,
  crowbar,
  cstruct,
  decompress,
  digestif,
  duff,
  findlib,
  fmt,
  fpath,
  getconf,
  hxd,
  ke,
  logs,
  lwt,
  mirage-flow,
  optint,
  psq,
  replaceVars,
  result,
  rresult,
}:

buildDunePackage (finalAttrs: {
  pname = "carton";
  version = "0.7.0";

  src = fetchurl {
    url = "https://github.com/mirage/ocaml-git/releases/download/carton-v${finalAttrs.version}/git-carton-v${finalAttrs.version}.tbz";
    hash = "sha256-vWkBJdP4ZpRCEwzrFMzsdHay4VyiXix/+1qzk+7yDvk=";
  };

  patches = [
    (replaceVars ./carton-find-getconf.patch {
      getconf = "${getconf}";
    })
  ];

  # remove changelogs for mimic and the git* packages
  postPatch = ''
    rm CHANGES.md
  '';

  nativeBuildInputs = [
    findlib
  ];

  buildInputs = [
    cmdliner
    digestif
    result
    rresult
    fpath
    bos
    hxd
  ];

  propagatedBuildInputs = [
    ke
    duff
    decompress
    cstruct
    optint
    bigstringaf
    checkseum
    logs
    psq
    fmt
  ];

  # Alcotest depends on cmdliner ≥ 2.0
  doCheck = false;

  checkInputs = [
    base64
    alcotest
    alcotest-lwt
    crowbar
    lwt
    mirage-flow
  ];

  meta = {
    description = "Implementation of PACKv2 file in OCaml";
    homepage = "https://github.com/mirage/ocaml-git";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sternenseemann ];
  };
})
