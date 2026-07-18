{
  alcotest-lwt,
  astring,
  buildDunePackage,
  cmdliner,
  fmt,
  hex,
  irmin,
  jsonm,
  logs,
  lwt,
  metrics,
  metrics-unix,
  mtime,
  ocaml-syntax-shims,
  ppx_irmin,
  qcheck-alcotest,
  vector,
}:

buildDunePackage {

  inherit (irmin) version src;
  pname = "irmin-test";
  nativeBuildInputs = [ ppx_irmin ];

  propagatedBuildInputs = [
    irmin
    ppx_irmin
    alcotest-lwt
    mtime
    astring
    fmt
    jsonm
    logs
    lwt
    metrics-unix
    ocaml-syntax-shims
    cmdliner
    metrics
  ];

  doCheck = true;

  checkInputs = [
    hex
    qcheck-alcotest
    vector
  ];

  meta = irmin.meta // {
    description = "Irmin test suite";
  };

}
