{
  lib,
  stdenv,
  autoPatchelfHook,
  vscode-extension-update-script,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = [ stdenv.cc.cc.lib ];

  mktplcRef =
    let
      sources = {
        "aarch64-darwin" = {
          arch = "darwin-arm64";
          hash = "sha256-yBJjt53eOazV9FB8qimerwXTX4vCIPC+lyXtau/3FyI=";
        };

        "aarch64-linux" = {
          arch = "linux-arm64";
          hash = "sha256-b46f0f99rjBivewC9jUbAFiKK+DS1XKv+AynUlKHliw=";
        };

        "x86_64-linux" = {
          arch = "linux-x64";
          hash = "sha256-uPmJyEq7X6uJzE1M5Xywax1mrnTcg6jOb9MlpKZ0WRk=";
        };
      };
    in
    {
      version = "7.3.53";
      name = "Kilo-Code";
      publisher = "kilocode";
    }
    // sources.${stdenv.hostPlatform.system}
      or (throw "Unsupported system ${stdenv.hostPlatform.system}");

  passthru.updateScript = vscode-extension-update-script { };

  meta = {
    description = "Open Source AI coding assistant for planning, building, and fixing code";
    homepage = "https://kilo.ai";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    maintainers = with lib.maintainers; [ xiaoxiangmoe ];

    platforms = [
      "aarch64-linux"
      "aarch64-darwin"
      "x86_64-linux"
    ];

    downloadPage = "https://marketplace.visualstudio.com/items?itemName=kilocode.Kilo-Code";
  };
}
