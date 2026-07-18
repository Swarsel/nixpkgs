{
  lib,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "1.3.5";
    hash = "sha256-QPuafIelmhdno/E2zr6NQChv0qjfjMFwx7v0Xat/gDc=";
    name = "anki";
    publisher = "jasew";
  };

  meta = {
    description = "Extension for interacting and sending cards to Anki";
    homepage = "https://github.com/jasonwilliams/anki";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.ethancedwards8 ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=jasew.anki";
  };
}
