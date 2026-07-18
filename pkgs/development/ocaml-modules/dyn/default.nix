{
  buildDunePackage,
  dune,
  ordering,
  pp,
}:

buildDunePackage {
  inherit (dune) version src;
  pname = "dyn";

  propagatedBuildInputs = [
    ordering
    pp
  ];

  dontAddPrefix = true;

  meta = dune.meta // {
    description = "Dynamic type";
  };
}
