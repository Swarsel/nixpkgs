{
  buildDunePackage,
  mirage-clock,
}:

buildDunePackage {
  inherit (mirage-clock)
    version
    src
    ;

  pname = "mirage-clock-solo5";

  propagatedBuildInputs = [
    mirage-clock
  ];

  meta = mirage-clock.meta // {
    description = "Paravirtual implementation of the MirageOS Clock interface";
  };
}
