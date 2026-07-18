{
  buildDunePackage,
  cacert,
  cmdliner,
  cohttp-lwt,
  conduit-lwt,
  conduit-lwt-unix,
  fmt,
  logs,
  magic-mime,
  ounit,
  ppx_sexp_conv,
}:

buildDunePackage {
  inherit (cohttp-lwt) version src;
  pname = "cohttp-lwt-unix";

  buildInputs = [
    cmdliner
    ppx_sexp_conv
  ];

  propagatedBuildInputs = [
    cohttp-lwt
    conduit-lwt
    conduit-lwt-unix
    fmt
    logs
    magic-mime
  ];

  # TODO(@sternenseemann): fail for unknown reason
  # https://github.com/mirage/ocaml-cohttp/issues/675#issuecomment-830692742
  doCheck = false;

  checkInputs = [
    ounit
    cacert
  ];

  meta = cohttp-lwt.meta // {
    description = "CoHTTP implementation for Unix and Windows using Lwt";
  };
}
