{
  buildAstalModule,
  gdk-pixbuf,
  json-glib,
  quarrel,
}:
buildAstalModule {
  buildInputs = [
    json-glib
    gdk-pixbuf
    quarrel
  ];

  name = "notifd";
  meta.description = "Astal module for notification daemon";
}
