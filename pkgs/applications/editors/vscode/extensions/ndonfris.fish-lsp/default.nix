{
  lib,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "0.1.22";
    hash = "sha256-rbxjPThdqVSbE6aZ8pcN2awMNypPaN0KQ/BzgO2Aqog=";
    name = "fish-lsp";
    publisher = "ndonfris";
  };

  meta = {
    description = "LSP implementation for the fish shell language";
    homepage = "https://github.com/ndonfris/fish-lsp";
    license = lib.licenses.mit;
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=ndonfris.fish-lsp";
  };
}
