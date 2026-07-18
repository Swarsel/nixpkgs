{
  alcotest,
  buildDunePackage,
  graphql,
  lwt,
}:

buildDunePackage {
  inherit (graphql) version src;
  pname = "graphql-lwt";

  propagatedBuildInputs = [
    graphql
    lwt
  ];

  doCheck = true;
  checkInputs = [ alcotest ];

  meta = graphql.meta // {
    description = "Build GraphQL schemas with Lwt support";
  };

}
