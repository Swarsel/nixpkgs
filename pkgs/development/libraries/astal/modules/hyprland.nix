{ buildAstalModule, json-glib }:
buildAstalModule {
  buildInputs = [ json-glib ];
  name = "hyprland";
  meta.description = "Astal module for Hyprland using IPC";
}
