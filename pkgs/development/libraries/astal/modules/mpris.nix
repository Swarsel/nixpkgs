{
  buildAstalModule,
  gvfs,
  json-glib,
  libsoup_3,
  quarrel,
}:
buildAstalModule {
  buildInputs = [
    gvfs
    json-glib
    libsoup_3
    quarrel
  ];

  name = "mpris";
  meta.description = "Astal module for mpris players";
}
