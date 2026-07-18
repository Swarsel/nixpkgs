{ lib, vscode-utils }:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "0.1.11";
    hash = "sha256-RIJwzScCRTL9SJZ3B9PFBkocnGdZ7D8uYjcXPsTumho=";
    name = "pylyzer";
    publisher = "pylyzer";
  };

  meta = {
    description = "VS Code extension for Pylyzer, a fast static code analyzer & language server for Python";
    homepage = "https://github.com/mtshiba/pylyzer/";
    license = lib.licenses.mit;
    maintainers = [ ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=pylyzer.pylyzer";
  };
}
