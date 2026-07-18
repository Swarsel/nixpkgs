{
  buildDunePackage,
  csexp,
  merlin,
}:

buildDunePackage {
  inherit (merlin) version src;
  pname = "merlin-lib";
  propagatedBuildInputs = [ csexp ];
  minimalOCamlVersion = "4.14";

  meta = merlin.meta // {
    description = "Merlin’s libraries";
  };
}
