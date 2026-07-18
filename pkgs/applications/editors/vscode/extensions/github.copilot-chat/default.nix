{
  lib,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "0.48.1";
    hash = "sha256-eFLfYMFxvgtZtmwLsxfneMjD4jOg8/Uk0Eu/6+A6odY=";
    name = "copilot-chat";
    publisher = "github";
  };

  meta = {
    description = "GitHub Copilot Chat is a companion extension to GitHub Copilot that houses experimental chat features";
    homepage = "https://github.com/features/copilot";
    license = lib.licenses.mit;
    maintainers = [ ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=GitHub.copilot-chat";
  };
}
