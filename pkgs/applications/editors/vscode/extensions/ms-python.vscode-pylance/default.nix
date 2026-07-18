{
  lib,
  pyright,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  buildInputs = [ pyright ];

  mktplcRef = {
    version = "2026.2.1";
    hash = "sha256-u1n4OqjBCAaRZe8Mu2vzYfZE6tpJQSQ3gSInJsNSSnQ=";
    name = "vscode-pylance";
    publisher = "MS-python";
  };

  meta = {
    description = "Performant, feature-rich language server for Python in VS Code";
    homepage = "https://github.com/microsoft/pylance-release";
    changelog = "https://marketplace.visualstudio.com/items/ms-python.vscode-pylance/changelog";
    license = lib.licenses.unfree;
    maintainers = [ lib.maintainers.ericthemagician ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=ms-python.vscode-pylance";
  };
}
