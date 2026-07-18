{
  buildDunePackage,
  timedesc,
}:

buildDunePackage {
  inherit (timedesc) version src sourceRoot;
  pname = "timedesc-tzdb";

  meta = timedesc.meta // {
    description = "Virtual library for Timedesc time zone database backends";
  };
}
