{ lib, vscode-utils }:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "0.1.4";
    hash = "sha256-7MX01miPbiOfnxXaCMg0yAKHXsBcwRUYuiU9yTzMGIQ=";
    name = "r-syntax";
    publisher = "REditorSupport";
  };

  meta = {
    description = "R Synxtax Highlight for Visual Studio Code";
    homepage = "https://github.com/REditorSupport/vscode-R-syntax";
    changelog = "https://marketplace.visualstudio.com/items/REditorSupport.r-syntax/changelog";
    license = lib.licenses.mit;

    maintainers = [
      lib.maintainers.ivyfanchiang
      lib.maintainers.pandapip1
    ];

    downloadPage = "https://marketplace.visualstudio.com/items?itemName=REditorSupport.r-syntax";
  };
}
