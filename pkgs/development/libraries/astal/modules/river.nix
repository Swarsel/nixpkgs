{
  buildAstalModule,
  json-glib,
  wl,
  wl-vapi-gen,
}:
buildAstalModule {
  nativeBuildInputs = [ wl-vapi-gen ];

  buildInputs = [
    json-glib
    wl
  ];

  name = "river";

  postUnpack = ''
    rm -rf $sourceRoot/subprojects
    mkdir -p $sourceRoot/subprojects
    cp -r --remove-destination $src/lib/wayland-glib $sourceRoot/subprojects/wayland-glib
  '';

  meta.description = "Astal module for River using IPC";
}
