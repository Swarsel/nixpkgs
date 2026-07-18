{
  lib,
  vscode-utils,
}:
vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "0.10.31";
    hash = "sha256-vECWkXwMWW6ZYQ+6lVpD1KAje1DY6z0APBS/0wIDMd4=";
    name = "cwtools-vscode";
    publisher = "tboby";
  };

  meta = {
    description = "Paradox Language Features for Visual Studio Code";
    homepage = "https://github.com/cwtools/cwtools-vscode";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.therobot2105 ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=tboby.cwtools-vscode";
  };
}
