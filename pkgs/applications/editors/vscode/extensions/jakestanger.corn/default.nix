{
  lib,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "0.1.0";
    hash = "sha256-6c9lxwJDVUuT3VKAbIohd0mRHFbfmfDgKfYJ+XET5hQ=";
    name = "corn";
    publisher = "JakeStanger";
  };

  meta = {
    description = "Visual Studio Code extension for Cornlang";
    homepage = "https://github.com/corn-config/corn-vscode";
    changelog = "https://marketplace.visualstudio.com/items/JakeStanger.corn/changelog";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ drupol ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=JakeStanger.corn";
  };
}
