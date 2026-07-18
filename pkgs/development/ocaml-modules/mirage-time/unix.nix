{
  buildDunePackage,
  duration,
  lwt,
  mirage-time,
}:

buildDunePackage {
  inherit (mirage-time) src version;
  pname = "mirage-time-unix";

  propagatedBuildInputs = [
    mirage-time
    lwt
    duration
  ];

  duneVersion = "3";

  meta = mirage-time.meta // {
    description = "Time operations for MirageOS on Unix";
  };
}
