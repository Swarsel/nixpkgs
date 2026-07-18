{
  buildDunePackage,
  ocsipersist-lib,
}:

buildDunePackage {
  inherit (ocsipersist-lib) src version;
  pname = "ocsipersist";
  propagatedBuildInputs = [ ocsipersist-lib ];

  meta = ocsipersist-lib.meta // {
    description = "Persistent key/value storage for OCaml using multiple backends";
  };
}
