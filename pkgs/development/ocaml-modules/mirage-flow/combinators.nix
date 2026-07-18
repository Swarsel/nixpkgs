{
  buildDunePackage,
  cstruct,
  logs,
  lwt,
  mirage-flow,
  mirage-mtime,
}:

buildDunePackage {
  inherit (mirage-flow) version src;
  pname = "mirage-flow-combinators";

  propagatedBuildInputs = [
    lwt
    logs
    cstruct
    mirage-mtime
    mirage-flow
  ];

  meta = mirage-flow.meta // {
    description = "Flow implementations and combinators for MirageOS specialized to lwt";
  };
}
