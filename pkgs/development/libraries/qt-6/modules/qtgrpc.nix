{
  grpc,
  protobuf,
  qtModule,
  qtbase,
  qtdeclarative,
}:

qtModule {
  pname = "qtgrpc";

  buildInputs = [
    protobuf
    grpc
  ];

  propagatedBuildInputs = [
    qtbase
    qtdeclarative
  ];
}
