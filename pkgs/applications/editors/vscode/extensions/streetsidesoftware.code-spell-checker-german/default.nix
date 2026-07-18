{ lib, vscode-utils }:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "2.3.4";
    hash = "sha256-zc0cv4AOswvYcC4xJOq2JEPMQ5qTj9Dad5HhxtNETEs=";
    name = "code-spell-checker-german";
    publisher = "streetsidesoftware";
  };

  meta = {
    description = "German dictionary extension for VS Code";
    homepage = "https://streetsidesoftware.github.io/vscode-spell-checker-german";
    changelog = "https://marketplace.visualstudio.com/items/streetsidesoftware.code-spell-checker-german/changelog";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.koschi13 ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=streetsidesoftware.code-spell-checker-german";
  };
}
