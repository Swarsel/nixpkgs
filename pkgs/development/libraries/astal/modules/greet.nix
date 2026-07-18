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

  name = "greet";
  meta.description = "Astal module for greetd using IPC";
}
