{ qtModule, qtbase }:

qtModule {
  pname = "qtsvg";

  outputs = [
    "out"
    "dev"
    "bin"
  ];

  propagatedBuildInputs = [ qtbase ];
}
