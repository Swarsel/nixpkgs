{
  alcotest,
  buildDunePackage,
  cstruct,
  fmt,
  logs,
  lwt,
  mirage-flow,
  mirage-flow-combinators,
}:

buildDunePackage {
  inherit (mirage-flow) version src;
  pname = "mirage-flow-unix";

  propagatedBuildInputs = [
    fmt
    logs
    mirage-flow
    lwt
    cstruct
  ];

  doCheck = true;

  checkInputs = [
    alcotest
    mirage-flow-combinators
  ];

  meta = mirage-flow.meta // {
    description = "Flow implementations and combinators for MirageOS on Unix";
  };
}
