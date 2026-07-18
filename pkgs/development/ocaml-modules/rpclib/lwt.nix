{
  alcotest-lwt,
  buildDunePackage,
  lwt,
  ppx_deriving_rpc,
  rpclib,
  yojson,
}:

buildDunePackage {
  inherit (rpclib) version src;
  pname = "rpclib-lwt";

  propagatedBuildInputs = [
    lwt
    rpclib
  ];

  doCheck = true;

  checkInputs = [
    alcotest-lwt
    ppx_deriving_rpc
    yojson
  ];

  meta = rpclib.meta // {
    description = "Library to deal with RPCs in OCaml - Lwt interface";
  };
}
