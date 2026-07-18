{
  lib,
  stdenv,
  autoPatchelfHook,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = [ (lib.getLib stdenv.cc.cc) ];

  mktplcRef =
    let
      sources = {
        "aarch64-darwin" = {
          arch = "darwin-arm64";
          hash = "sha256-QPRZG7/Pjo9uboJl/RH0cdNf+zGM+ZRxdaMULxl34Jk=";
        };

        "aarch64-linux" = {
          arch = "linux-arm64";
          hash = "sha256-QngCharrjiDKrY7RgWtKzIJxjXazuRvpuHVUAxknWfA=";
        };

        "x86_64-linux" = {
          arch = "linux-x64";
          hash = "sha256-4GiTNT+UPdTth9VDhHTXfqhQ5gM6vfLAaU5Cy3VMTCI=";
        };
      };
    in
    {
      version = "2.0.0";
      name = "continue";
      publisher = "Continue";
    }
    // sources.${stdenv.system} or (throw "Unsupported system: ${stdenv.system}");

  meta = {
    description = "Open-source AI code assistant";
    homepage = "https://github.com/continuedev/continue";
    changelog = "https://marketplace.visualstudio.com/items/Continue.continue";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ flacks ];

    platforms = [
      "x86_64-linux"
      "aarch64-darwin"
      "aarch64-linux"
    ];

    downloadPage = "https://marketplace.visualstudio.com/items?itemName=Continue.continue";
  };
}
