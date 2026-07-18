{
  alcotest,
  buildDunePackage,
  cmdliner,
  fmt,
  logs,
  lwt,
  re,
}:

buildDunePackage {
  inherit (alcotest) version src;
  pname = "alcotest-lwt";

  propagatedBuildInputs = [
    alcotest
    logs
    lwt
    fmt
  ];

  doCheck = true;

  checkInputs = [
    re
    cmdliner
  ];

  duneVersion = "3";

  meta = alcotest.meta // {
    description = "Lwt-based helpers for Alcotest";
  };

}
