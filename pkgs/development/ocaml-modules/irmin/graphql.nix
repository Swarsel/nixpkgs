{
  alcotest,
  alcotest-lwt,
  buildDunePackage,
  cacert,
  cohttp-lwt,
  cohttp-lwt-unix,
  git-unix,
  graphql-cohttp,
  graphql-lwt,
  irmin,
  logs,
  yojson,
}:

buildDunePackage {

  inherit (irmin) version src;
  pname = "irmin-graphql";

  propagatedBuildInputs = [
    cohttp-lwt
    cohttp-lwt-unix
    graphql-cohttp
    graphql-lwt
    irmin
    git-unix
  ];

  doCheck = true;

  checkInputs = [
    alcotest
    alcotest-lwt
    logs
    yojson
    cacert
  ];

  meta = irmin.meta // {
    description = "GraphQL server for Irmin";
  };
}
