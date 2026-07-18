{
  buildAstalModule,
  json-glib,
}:
buildAstalModule {
  buildInputs = [ json-glib ];
  name = "battery";
  meta.description = "Astal module for upowerd devices (DBus proxy)";
}
