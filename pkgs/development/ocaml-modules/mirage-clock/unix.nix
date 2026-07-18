{
  buildDunePackage,
  dune-configurator,
  mirage-clock,
}:

buildDunePackage {
  inherit (mirage-clock) version src;
  pname = "mirage-clock-unix";
  buildInputs = [ dune-configurator ];
  propagatedBuildInputs = [ mirage-clock ];

  meta = mirage-clock.meta // {
    description = "Unix-based implementation for the MirageOS Clock interface";
  };
}
