{
  buildDunePackage,
  logs,
  lwt,
  metrics,
}:

buildDunePackage {
  inherit (metrics) version src;
  pname = "metrics-lwt";

  propagatedBuildInputs = [
    logs
    lwt
    metrics
  ];

  duneVersion = "3";

  meta = metrics.meta // {
    description = "Lwt backend for the Metrics library";
  };

}
