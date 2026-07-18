{
  alcotest,
  alcotest-lwt,
  asetmap,
  astring,
  buildDunePackage,
  cmdliner,
  cohttp-lwt,
  cohttp-lwt-unix,
  fmt,
  logs,
  lwt,
  prometheus,
  re,
}:

buildDunePackage {
  inherit (prometheus)
    version
    src
    ;

  pname = "prometheus-app";

  propagatedBuildInputs = [
    asetmap
    astring
    cmdliner
    cohttp-lwt
    cohttp-lwt-unix
    fmt
    logs
    lwt
    prometheus
    re
  ];

  doCheck = true;

  checkInputs = [
    alcotest
    alcotest-lwt
  ];

  meta = prometheus.meta // {
    description = "A web-server reporting prometheus metrics.";
  };
}
