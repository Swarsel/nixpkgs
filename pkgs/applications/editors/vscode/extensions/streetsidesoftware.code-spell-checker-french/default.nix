{ lib, vscode-utils }:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "0.4.4";
    hash = "sha256-9BVSQFysgKPKp1e6noSv2szVSQvYH7nOuphJeiso55s=";
    name = "code-spell-checker-french";
    publisher = "streetsidesoftware";
  };

  meta = {
    description = "French dictionary extension for VS Code";
    homepage = "https://github.com/streetsidesoftware/vscode-cspell-dict-extensions#readme";
    changelog = "https://marketplace.visualstudio.com/items/streetsidesoftware.code-spell-checker-french/changelog";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ aduh95 ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=streetsidesoftware.code-spell-checker-french";
  };
}
