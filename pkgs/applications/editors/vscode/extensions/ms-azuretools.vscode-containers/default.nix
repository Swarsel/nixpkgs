{
  lib,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "2.4.5";
    hash = "sha256-Js+403StdF3WmlHOiB78UKM77njReuKOiQ9NHnFljs8=";
    name = "vscode-containers";
    publisher = "ms-azuretools";
  };

  meta = {
    description = "Container Tools Extension for Visual Studio Code ";
    homepage = "https://github.com/microsoft/vscode-containers";
    changelog = "https://github.com/microsoft/vscode-containers/releases";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.m0nsterrr ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-containers";
  };
}
