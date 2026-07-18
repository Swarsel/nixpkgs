{
  alcotest,
  buildDunePackage,
  fmt,
  irmin,
  irmin-test,
  logs,
  lwt,
}:

buildDunePackage {

  inherit (irmin) version src;
  pname = "irmin-chunk";

  propagatedBuildInputs = [
    irmin
    fmt
    logs
    lwt
  ];

  doCheck = true;

  checkInputs = [
    alcotest
    irmin-test
  ];

  meta = irmin.meta // {
    description = "Irmin backend which allow to store values into chunks";
  };

}
