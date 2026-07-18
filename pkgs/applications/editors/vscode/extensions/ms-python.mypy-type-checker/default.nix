{
  lib,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "2026.6.0";
    hash = "sha256-Sis9Tm5uWTyAIJnHvdh/dwOs580YprqDQ3XP8FhWvw0=";
    name = "mypy-type-checker";
    publisher = "ms-python";
  };

  meta = {
    description = "VSCode extension for type checking support for Python files using Mypy";
    homepage = "https://github.com/microsoft/vscode-mypy";
    changelog = "https://github.com/microsoft/vscode-mypy/releases";
    license = lib.licenses.mit;
    maintainers = [ ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=ms-python.mypy-type-checker";
  };
}
