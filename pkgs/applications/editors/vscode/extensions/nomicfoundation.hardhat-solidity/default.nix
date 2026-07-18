{ lib, vscode-utils }:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "0.8.29";
    hash = "sha256-0WC4MBCjY2TyZmeBtiCsKD95dudtCfo2HzvMWorWbOY=";
    name = "hardhat-solidity";
    publisher = "nomicfoundation";
  };

  meta = {
    description = "Solidity and Hardhat support for Visual Studio Code";
    homepage = "https://github.com/NomicFoundation/hardhat-vscode";
    changelog = "https://github.com/NomicFoundation/hardhat-vscode/blob/main/client/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.iamanaws ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=nomicfoundation.hardhat-solidity";
  };
}
