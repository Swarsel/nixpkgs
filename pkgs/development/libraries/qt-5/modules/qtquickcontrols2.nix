{ qtModule, qtdeclarative }:

qtModule {
  pname = "qtquickcontrols2";

  outputs = [
    "out"
    "dev"
    "bin"
  ];

  propagatedBuildInputs = [ qtdeclarative ];
}
