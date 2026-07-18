{
  lib,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "0.8.2";
    hash = "sha256-qVZf+fOrdnDJzRUVA3GhTUDLhdJrH2tPRgvYW+ymVGw=";
    name = "teamtype";
    publisher = "teamtype";
  };

  meta = {
    description = "Extension for real-time co-editing of local text files";
    homepage = "https://github.com/teamtype/teamtype/tree/main/vscode-plugin";
    license = lib.licenses.agpl3Plus;
    maintainers = [ lib.maintainers.ethancedwards8 ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=teamtype.teamtype";
    teams = [ lib.teams.ngi ];
  };
}
