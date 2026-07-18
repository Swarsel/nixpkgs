{
  lib,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "2026.6.0";
    hash = "sha256-lJl+nQyLjnkuMfewYXcrU+Nne7R2foUPn50TtE9OqDA=";
    name = "pylint";
    publisher = "ms-python";
  };

  meta = {
    description = "Python linting support for VS Code using Pylint";
    homepage = "https://github.com/microsoft/vscode-pylint";
    changelog = "https://marketplace.visualstudio.com/items/ms-python.pylint/changelog";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.amadejkastelic ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=ms-python.pylint";
  };
}
