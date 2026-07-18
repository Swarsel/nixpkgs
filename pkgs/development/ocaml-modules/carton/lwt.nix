{
  alcotest,
  alcotest-lwt,
  base64,
  bigstringaf,
  bos,
  buildDunePackage,
  carton,
  checkseum,
  cstruct,
  decompress,
  digestif,
  fmt,
  fpath,
  git-binary, # pkgs.git
  ke,
  logs,
  lwt,
  mirage-flow,
  optint,
  result,
  rresult,
  stdlib-shims,
}:

buildDunePackage {
  inherit (carton) version src postPatch;
  inherit (carton) meta;
  pname = "carton-lwt";

  propagatedBuildInputs = [
    carton
    lwt
    decompress
    optint
    bigstringaf
  ];

  # Tests fail with git 2.41
  # see https://github.com/mirage/ocaml-git/issues/617
  doCheck = false;

  nativeCheckInputs = [
    git-binary
  ];

  checkInputs = [
    alcotest
    alcotest-lwt
    cstruct
    fmt
    logs
    mirage-flow
    result
    rresult
    ke
    base64
    bos
    checkseum
    digestif
    fpath
    stdlib-shims
  ];

  duneVersion = "3";
}
