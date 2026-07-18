{
  buildDunePackage,
  ipaddr,
  ipaddr-cstruct,
  ounit2,
  ppx_sexp_conv,
}:

buildDunePackage {
  inherit (ipaddr) version src;
  pname = "ipaddr-sexp";
  propagatedBuildInputs = [ ipaddr ];
  doCheck = true;

  checkInputs = [
    ipaddr-cstruct
    ounit2
    ppx_sexp_conv
  ];

  duneVersion = "3";

  meta = ipaddr.meta // {
    description = "Library for manipulation of IP address representations usnig sexp";
  };
}
