{
  lib,
  alcotest,
  astring,
  buildDunePackage,
  cohttp,
  cohttp-lwt-unix,
  digestif,
  graphql,
  graphql-lwt,
  ocaml-crunch,
  ocplib-endian,
}:

buildDunePackage (finalAttrs: {
  inherit (graphql) version src;
  pname = "graphql-cohttp";

  postPatch = ''
    substituteInPlace graphql-cohttp/src/graphql_websocket.ml \
      --replace-fail "~flush:true ()" "~version:\`HTTP_1_1 ()"
  '';

  nativeBuildInputs = [ ocaml-crunch ];

  propagatedBuildInputs = [
    astring
    cohttp
    digestif
    graphql
    ocplib-endian
  ];

  doCheck = true;

  checkInputs = lib.optionals finalAttrs.doCheck [
    alcotest
    cohttp-lwt-unix
    graphql-lwt
  ];

  duneVersion = "3";

  meta = graphql.meta // {
    description = "Run GraphQL servers with “cohttp”";
  };

})
