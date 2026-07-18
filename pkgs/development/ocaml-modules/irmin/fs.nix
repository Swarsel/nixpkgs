{
  alcotest,
  astring,
  buildDunePackage,
  irmin,
  irmin-test,
  irmin-watcher,
  logs,
  lwt,
}:

buildDunePackage {

  inherit (irmin) version src;
  pname = "irmin-fs";

  propagatedBuildInputs = [
    irmin
    astring
    logs
    lwt
  ];

  doCheck = true;

  checkInputs = [
    alcotest
    irmin-test
    irmin-watcher
  ];

  meta = irmin.meta // {
    description = "Generic file-system backend for Irmin";
  };

}
