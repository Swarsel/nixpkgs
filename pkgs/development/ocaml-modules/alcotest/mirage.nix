{
  lib,
  alcotest,
  buildDunePackage,
  duration,
  logs,
  lwt,
  mirage-clock,
}:

buildDunePackage {
  inherit (alcotest) version src;
  pname = "alcotest-mirage";

  propagatedBuildInputs = [
    alcotest
    lwt
    logs
    mirage-clock
    duration
  ];

  doCheck = true;
  duneVersion = "3";

  meta = alcotest.meta // {
    description = "Mirage implementation for Alcotest";

    maintainers = with lib.maintainers; [
      ulrikstrid
    ];
  };
}
