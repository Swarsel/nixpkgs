{
  lib,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "0.825.5";
    hash = "sha256-UKkrdxHlbcdpd3RQxNpZVBINZlncPv7e5RETnj/19Ts=";
    name = "vscode-augment";
    publisher = "augment";
  };

  meta = {
    description = "AI-powered coding assistant for VSCode";
    homepage = "https://augmentcode.com/";
    changelog = "https://marketplace.visualstudio.com/items/augment.vscode-augment/changelog";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = [ lib.maintainers.matteopacini ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=augment.vscode-augment";
  };
}
