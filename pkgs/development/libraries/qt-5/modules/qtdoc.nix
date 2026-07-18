{ qtModule, qtdeclarative }:

qtModule {
  pname = "qtdoc";
  outputs = [ "out" ];
  propagatedBuildInputs = [ qtdeclarative ];
}
