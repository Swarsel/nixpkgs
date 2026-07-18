{
  buildDunePackage,
  conduit,
  lwt,
  ppx_sexp_conv,
  sexplib0,
}:

buildDunePackage {
  inherit (conduit) version src;
  pname = "conduit-lwt";
  buildInputs = [ ppx_sexp_conv ];

  propagatedBuildInputs = [
    conduit
    lwt
    sexplib0
  ];

  meta = conduit.meta // {
    description = "Network connection establishment library for Lwt";
  };
}
