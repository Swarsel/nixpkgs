{
  lib,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "10.16.1";
    hash = "sha256-QhqBCQjWADmuPK9ryMCoQPWE1pyIeO9XfYvN40ipL0Y=";
    name = "latex-workshop";
    publisher = "James-Yu";
  };

  meta = {
    description = "LaTeX Workshop Extension";
    homepage = "https://github.com/James-Yu/LaTeX-Workshop";
    changelog = "https://marketplace.visualstudio.com/items/James-Yu.latex-workshop/changelog";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.therobot2105 ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=James-Yu.latex-workshop";
  };
}
