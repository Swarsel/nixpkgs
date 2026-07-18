{
  lib,
  vscode-utils,
}:
vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "3.0.0";
    hash = "sha256-NadsB/6kUQ7/d9o3rUc7889jO+4MdvBhtyI4UUGpzqk=";
    name = "arepl";
    publisher = "almenon";
  };

  meta = {
    description = "Preferred dark/light themes by John Papa";
    homepage = "https://github.com/Almenon/AREPL-vscode";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.therobot2105 ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=almenon.arepl";
  };
}
