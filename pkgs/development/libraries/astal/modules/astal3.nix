{
  buildAstalModule,
  gtk-layer-shell,
  gtk3,
  io,
}:
buildAstalModule {
  buildInputs = [ io ];

  propagatedBuildInputs = [
    gtk3
    gtk-layer-shell
  ];

  name = "astal3";
  sourceRoot = "lib/astal/gtk3";
  meta.description = "Astal module for GTK3 widgets";
}
