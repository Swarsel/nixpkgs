{ lib, vscode-utils }:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "1.16.0";
    hash = "sha256-cnKYDrExL3yDJkEofWPglzMa50KDMgKQxsM5zK1RaBs=";
    name = "mongodb-vscode";
    publisher = "mongodb";
  };

  meta = {
    description = "Extension for VS Code that makes it easy to work with your data in MongoDB";
    homepage = "https://github.com/mongodb-js/vscode";
    changelog = "https://github.com/mongodb-js/vscode/blob/main/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=mongodb.mongodb-vscode";
  };
}
