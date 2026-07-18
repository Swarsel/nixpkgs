{ lib, vscode-utils }:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "0.25.0";
    hash = "sha256-5SmCkHGCS8dYfdSm3NRk091jH44m+7kkj+VL84YKM4g=";
    name = "solargraph";
    publisher = "castwide";
  };

  meta = {
    description = "Ruby language server featuring code completion, intellisense, and inline documentation";
    homepage = "https://github.com/castwide/vscode-solargraph";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.bbenno ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=castwide.solargraph";
  };
}
