{
  lib,
  buildDunePackage,
  domain-name,
  macaddr,
  ounit2,
  ppx_sexp_conv,
  stdlib-shims,
}:

buildDunePackage {
  inherit (macaddr) version src;
  pname = "ipaddr";

  propagatedBuildInputs = [
    macaddr
    domain-name
    stdlib-shims
  ];

  doCheck = true;

  checkInputs = [
    ppx_sexp_conv
    ounit2
  ];

  duneVersion = "3";
  minimalOCamlVersion = "4.08";

  meta = macaddr.meta // {
    description = "Library for manipulation of IP (and MAC) address representations";

    maintainers = with lib.maintainers; [
      ericbmerritt
    ];
  };
}
