{ lib, vscode-utils }:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "0.1.0";
    hash = "sha256-u50RJ7ETVFUC43mp94VJsR931b9REBaTyRhZE7muoLw=";
    name = "adjust-heading-level";
    publisher = "dendron";
  };

  meta = {
    description = "VSCode extension to adjust the heading level of the selected text";
    homepage = "https://github.com/kevinslin/adjust-heading-level";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.ivyfanchiang ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=dendron.adjust-heading-level";
  };
}
