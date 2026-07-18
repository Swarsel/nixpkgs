{
  alcotest,
  alcotest-lwt,
  astring,
  buildDunePackage,
  checkseum,
  cmdliner,
  fmt,
  index,
  irmin,
  irmin-test,
  logs,
  lwt,
  mtime,
  optint,
  ppx_irmin,
  rusage,
}:

buildDunePackage {
  inherit (irmin) version src;
  pname = "irmin-pack";
  nativeBuildInputs = [ ppx_irmin ];

  propagatedBuildInputs = [
    index
    irmin
    optint
    fmt
    logs
    lwt
    mtime
    cmdliner
    checkseum
    rusage
  ];

  doCheck = true;

  checkInputs = [
    astring
    alcotest
    alcotest-lwt
    irmin-test
  ];

  minimalOCamlVersion = "4.12";

  meta = irmin.meta // {
    description = "Irmin backend which stores values in a pack file";
    mainProgram = "irmin_fsck";
  };

}
