{ buildAstalModule, networkmanager }:
buildAstalModule {
  buildInputs = [ networkmanager ];
  name = "network";
  meta.description = "Astal module for NetworkManager";
}
