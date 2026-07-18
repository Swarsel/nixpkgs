{
  buildDunePackage,
  fmt,
  irmin,
  mirage-clock,
  ptime,
}:

buildDunePackage {
  inherit (irmin) version src;
  pname = "irmin-mirage";

  propagatedBuildInputs = [
    irmin
    fmt
    ptime
    mirage-clock
  ];

  meta = irmin.meta // {
    description = "MirageOS-compatible Irmin stores";
  };
}
