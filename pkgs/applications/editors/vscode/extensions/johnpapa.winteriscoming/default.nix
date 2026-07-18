{ lib, vscode-utils }:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "1.4.4";
    hash = "sha256-47zCB7VDj+gYXUeblbNsWnGMJt4U4UMyqU1NYTmz2Jc=";
    name = "winteriscoming";
    publisher = "johnpapa";
  };

  meta = {
    description = "Preferred dark/light themes by John Papa";
    homepage = "https://github.com/johnpapa/vscode-winteriscoming";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.therobot2105 ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=johnpapa.winteriscoming";
  };
}
