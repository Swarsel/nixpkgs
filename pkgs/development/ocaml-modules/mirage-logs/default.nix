{
  lib,
  fetchurl,
  alcotest,
  buildDunePackage,
  cmdliner,
  fmt,
  logs,
  lwt,
  mirage-clock,
  ptime,
}:

buildDunePackage (finalAttrs: {
  pname = "mirage-logs";
  version = "2.1.0";

  src = fetchurl {
    url = "https://github.com/mirage/mirage-logs/releases/download/v${finalAttrs.version}/mirage-logs-${finalAttrs.version}.tbz";
    hash = "sha256-rorCsgw7QCQmjotr465KShQGWdoUM88djpwgqwBGnLs=";
  };

  propagatedBuildInputs = [
    logs
    fmt
    ptime
    mirage-clock
    cmdliner
  ];

  doCheck = true;

  checkInputs = [
    lwt
    alcotest
  ];

  duneVersion = "3";

  meta = {
    description = "Reporter for the Logs library that writes log messages to stderr, using a Mirage `CLOCK` to add timestamps";
    homepage = "https://github.com/mirage/mirage-logs";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.vbgl ];
  };
})
