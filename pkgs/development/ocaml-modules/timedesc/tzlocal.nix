{
  buildDunePackage,
  timedesc,
}:

buildDunePackage {
  inherit (timedesc) version src sourceRoot;
  pname = "timedesc-tzlocal";

  meta = timedesc.meta // {
    description = "Virtual library for Timedesc local time zone detection backends";
  };
}
