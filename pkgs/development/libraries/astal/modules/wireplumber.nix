{ buildAstalModule, wireplumber }:
buildAstalModule {
  buildInputs = [ wireplumber ];
  name = "wireplumber";
  meta.description = "Astal module for wireplumber";
}
