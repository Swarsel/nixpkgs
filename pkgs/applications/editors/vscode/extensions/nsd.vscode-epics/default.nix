{
  lib,
  vscode-utils,
}:
vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "1.1.0";
    hash = "sha256-ljd0UFFv0hA5jiM6xl4xOjM+z7u9I+H8O/j6m/U5U2c=";
    name = "vscode-epics";
    publisher = "nsd";
  };

  meta = {
    description = "EPICS syntax highlighting and tools";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.minijackson ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=nsd.vscode-epics";
  };
}
