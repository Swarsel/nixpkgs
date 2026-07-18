{ buildAstalModule, wl-vapi-gen }:
buildAstalModule {
  nativeBuildInputs = [ wl-vapi-gen ];
  name = "wl";
  meta.description = "Central wayland connection manager";
}
