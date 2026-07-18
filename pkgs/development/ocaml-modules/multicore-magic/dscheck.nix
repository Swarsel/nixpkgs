{
  lib,
  buildDunePackage,
  dscheck,
  multicore-magic,
}:

buildDunePackage {
  inherit (multicore-magic) src version;
  pname = "multicore-magic-dscheck";

  propagatedBuildInputs = [
    dscheck
  ];

  meta = multicore-magic.meta // {
    description = "Implementation of multicore-magic API using the atomic module of DScheck to make DScheck tests possible in libraries using multicore-magic";
  };
}
