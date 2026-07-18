{ qtModule, qtdeclarative }:

qtModule {
  pname = "qtgraphicaleffects";

  outputs = [
    "out"
    "dev"
  ];

  propagatedBuildInputs = [ qtdeclarative ];
}
