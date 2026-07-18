{
  lib,
  alcotest,
  buildDunePackage,
  ppx_deriving,
  ppxlib,
  rpclib,
  yojson,
}:

buildDunePackage {
  inherit (rpclib) version src;
  pname = "ppx_deriving_rpc";

  propagatedBuildInputs = [
    ppxlib
    rpclib
    ppx_deriving
  ];

  doCheck = true;

  checkInputs = [
    alcotest
    yojson
  ];

  meta = {
    description = "Ppx deriver for ocaml-rpc";
    homepage = "https://github.com/mirage/ocaml-rpc";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.vyorkin ];
  };
}
