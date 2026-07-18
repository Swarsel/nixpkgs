{
  alcotest,
  buildDunePackage,
  graphql_parser,
  rresult,
  yojson,
}:

buildDunePackage {
  inherit (graphql_parser) version src;
  pname = "graphql";

  propagatedBuildInputs = [
    graphql_parser
    rresult
    yojson
  ];

  doCheck = true;
  checkInputs = [ alcotest ];
  duneVersion = "3";

  meta = graphql_parser.meta // {
    description = "Build GraphQL schemas and execute queries against them";
  };

}
