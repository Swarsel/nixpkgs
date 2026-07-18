{
  fetchurl,
  buildDunePackage,
  ppx_deriving,
  testo,
}:

buildDunePackage {
  inherit (testo) version src;
  pname = "testo-diff";
  propagatedBuildInputs = [ ppx_deriving ];

  meta = testo.meta // {
    description = "Pure-OCaml diff implementation";
  };
}
