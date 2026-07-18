{
  lib,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "2026.6.0";
    hash = "sha256-bWkn9XPgHqYDOlT3W0kJvF7q1WnQblwhM9J2VecXjO0=";
    name = "isort";
    publisher = "ms-python";
  };

  meta = {
    description = "Import sorting extension for Visual Studio Code using isort";
    homepage = "https://github.com/microsoft/vscode-isort";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sikmir ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=ms-python.isort";
  };
}
