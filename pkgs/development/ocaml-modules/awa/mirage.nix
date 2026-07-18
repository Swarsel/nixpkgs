{
  awa,
  buildDunePackage,
  duration,
  logs,
  lwt,
  mirage-flow,
  mirage-mtime,
  mirage-sleep,
  mtime,
}:

buildDunePackage {
  inherit (awa) version src;
  inherit (awa) meta;
  pname = "awa-mirage";

  propagatedBuildInputs = [
    awa
    mtime
    lwt
    mirage-flow
    mirage-sleep
    logs
    duration
    mirage-mtime
  ];
}
