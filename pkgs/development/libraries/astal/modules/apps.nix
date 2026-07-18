{
  buildAstalModule,
  json-glib,
}:
buildAstalModule {
  buildInputs = [ json-glib ];
  name = "apps";
  meta.description = "Astal module for application query";
}
