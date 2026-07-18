{
  lib,
  httpyac,
  vscode-utils,
}:

let
  version = "6.16.7";
in
vscode-utils.buildVscodeMarketplaceExtension {
  buildInputs = [ httpyac ];

  mktplcRef = {
    inherit version;
    hash = "sha256-NAyVsEb3QBgq+cGWF03kjk2bQ8L5mulYYyIhIhjNVMQ=";
    name = "vscode-httpyac";
    publisher = "anweber";
  };

  meta = {
    description = "Quickly and easily send REST, Soap, GraphQL, GRPC, MQTT, RabbitMQ and WebSocket requests directly within Visual Studio Code";
    homepage = "https://github.com/AnWeber/vscode-httpyac/";
    changelog = "https://github.com/AnWeber/vscode-httpyac/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=anweber.vscode-httpyac";
  };
}
