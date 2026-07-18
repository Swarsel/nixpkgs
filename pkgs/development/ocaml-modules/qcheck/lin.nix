{
  buildDunePackage,
  qcheck-multicoretests-util,
}:

buildDunePackage {
  inherit (qcheck-multicoretests-util) version src;
  pname = "qcheck-lin";
  propagatedBuildInputs = [ qcheck-multicoretests-util ];
  doCheck = true;

  meta = qcheck-multicoretests-util.meta // {
    description = "Multicore testing library for OCaml";
  };
}
