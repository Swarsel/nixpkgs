{
  lib,
  azure-cli,
  bicep,
  bicep-lsp,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  buildInputs = [
    azure-cli
    bicep
    bicep-lsp
  ];

  mktplcRef = {
    version = "0.43.8";
    hash = "sha256-OweBVc8s+CEaCW4IZu43HaXOAL/PBjnunCEoPsq0pI0=";
    name = "vscode-bicep";
    publisher = "ms-azuretools";
  };

  meta = {
    description = "Visual Studio Code extension for Bicep language";
    homepage = "https://github.com/Azure/bicep/tree/main/src/vscode-bicep";
    license = lib.licenses.mit;
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep";
  };
}

# Instructions on Usage
#
# programs.vscode = {
#  enable = true;
#  package = pkgs.codium;
#  profiles.default = {
#    "dotnetAcquisitionExtension.sharedExistingDotnetPath" = "${pkgs.dotnet-sdk_8}/bin/dotnet";
#    "dotnetAcquisitionExtension.existingDotnetPath" = [
#       {
#          "extensionId" = "ms-dotnettools.csharp";
#          "path" = "${pkgs.dotnet-sdk_8}/bin/dotnet";
#       }
#       {
#          "extensionId" = "ms-dotnettools.csdevkit";
#          "path" = "${pkgs.dotnet-sdk_8}/bin/dotnet";
#       }
#       {
#          "extensionId" = "ms-azuretools.vscode-bicep";
#          "path" = "${pkgs.dotnet-sdk_8}/bin/dotnet";
#       }
#    ];
#  extensions = with pkgs.vscode-extensions; [
#    ms-azuretools.vscode-bicep
#    ms-dotnettools.csdevkit
#    ms-dotnettools.csharp
#    ms-dotnettools.vscode-dotnet-runtime
#  ];
# };
