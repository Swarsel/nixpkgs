{
  buildDunePackage,
  duration,
  fmt,
  lwt,
  metrics,
}:

buildDunePackage {
  inherit (metrics) version src;
  pname = "metrics-influx";

  propagatedBuildInputs = [
    duration
    fmt
    lwt
    metrics
  ];

  duneVersion = "3";

  meta = metrics.meta // {
    description = "Influx reporter for the Metrics library";
  };
}
