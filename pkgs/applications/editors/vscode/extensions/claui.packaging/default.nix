{
  lib,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "0.2.5";
    hash = "sha256-WGs00Q1oa8Nz9dpKn3iZSjrhR0VKUwJWPGdm+wWtoxs=";
    name = "packaging";
    publisher = "claui";
  };

  meta = {
    description = "Visual Studio Code extension for PKGBUILDs in the Arch User Repository (AUR)";
    homepage = "https://github.com/claui/vscode-packaging";
    changelog = "https://github.com/claui/vscode-packaging/releases";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ilai-deutel ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=claui.packaging";
  };
}
