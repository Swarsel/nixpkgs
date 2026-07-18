{
  appmenu-glib-translator,
  buildAstalModule,
  json-glib,
}:
buildAstalModule {
  buildInputs = [
    json-glib
    appmenu-glib-translator
  ];

  name = "tray";
  meta.description = "Astal module for StatusNotifierItem";
}
