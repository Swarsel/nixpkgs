{
  buildAstalModule,
  gtk4,
  gtk4-layer-shell,
  io,
}:
buildAstalModule {
  buildInputs = [
    io
    gtk4
    gtk4-layer-shell
  ];

  name = "astal4";
  sourceRoot = "lib/astal/gtk4";
  meta.description = "Astal module for GTK4 widgets";
}
