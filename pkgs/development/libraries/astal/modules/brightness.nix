{
  buildAstalModule,
  json-glib,
  quarrel,
}:
buildAstalModule {
  buildInputs = [
    json-glib
    quarrel
  ];

  name = "brightness";
  meta.description = "Astal module for brightness devices";
}
