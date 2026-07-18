{
  buildDunePackage,
  macaddr,
  macaddr-cstruct,
  ounit2,
  ppx_sexp_conv,
}:

buildDunePackage {
  inherit (macaddr) version src;
  pname = "macaddr-sexp";
  propagatedBuildInputs = [ ppx_sexp_conv ];
  doCheck = true;

  checkInputs = [
    macaddr-cstruct
    ounit2
  ];

  duneVersion = "3";

  meta = macaddr.meta // {
    description = "Library for manipulation of MAC address representations using sexp";
  };
}
