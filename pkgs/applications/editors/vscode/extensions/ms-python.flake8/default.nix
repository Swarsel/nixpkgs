{
  lib,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "2026.6.0";
    hash = "sha256-n++DEjZsNY3YkvldyWuk3dCYgFbIxqMOun42lWEHGog=";
    name = "flake8";
    publisher = "ms-python";
  };

  meta = {
    description = "Python linting support for VS Code using Flake8";
    homepage = "https://github.com/microsoft/vscode-flake8";
    changelog = "https://marketplace.visualstudio.com/items/ms-python.flake8/changelog";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.amadejkastelic ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=ms-python.flake8";
  };
}
