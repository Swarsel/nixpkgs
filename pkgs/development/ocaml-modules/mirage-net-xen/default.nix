{
  buildDunePackage,
  cstruct,
  io-page,
  logs,
  lwt,
  lwt-dllist,
  mirage-net,
  mirage-xen,
  netchannel,
  ppx_sexp_conv,
}:

buildDunePackage {
  inherit (netchannel)
    src
    version
    meta
    ;

  pname = "mirage-net-xen";

  nativeBuildInputs = [
    ppx_sexp_conv
  ];

  propagatedBuildInputs = [
    lwt
    cstruct
    netchannel
    mirage-net
    mirage-xen
    io-page
    lwt-dllist
    logs
  ];

  duneVersion = "3";
}
