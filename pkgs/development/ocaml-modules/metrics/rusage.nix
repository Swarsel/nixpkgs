{
  buildDunePackage,
  fmt,
  logs,
  metrics,
}:

buildDunePackage {
  inherit (metrics) src version;
  pname = "metrics-rusage";

  propagatedBuildInputs = [
    fmt
    logs
    metrics
  ];

  doCheck = true;
  duneVersion = "3";
  minimalOCamlVersion = "4.08";

  meta = metrics.meta // {
    description = "Resource usage (getrusage) sources for the Metrics library";
  };
}
