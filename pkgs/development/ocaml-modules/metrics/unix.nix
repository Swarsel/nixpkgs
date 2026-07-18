{
  buildDunePackage,
  gnuplot,
  lwt,
  metrics,
  metrics-lwt,
  mtime,
  uuidm,
}:

buildDunePackage {

  inherit (metrics) version src;
  pname = "metrics-unix";

  propagatedBuildInputs = [
    gnuplot
    lwt
    metrics
    mtime
    uuidm
  ];

  doCheck = true;
  nativeCheckInputs = [ gnuplot ];
  checkInputs = [ metrics-lwt ];

  meta = metrics.meta // {
    description = "Unix backend for the Metrics library";
  };

}
