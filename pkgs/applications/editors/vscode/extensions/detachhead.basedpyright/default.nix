{
  lib,
  vscode-utils,
  ...
}:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "1.39.9";
    hash = "sha256-Iycuj7EXzRwVgvpk0KXa3dNw2rL21DnG4ohqIExS6Go=";
    name = "basedpyright";
    publisher = "detachhead";
  };

  meta = {
    description = "VS Code static type checking for Python (but based)";
    homepage = "https://docs.basedpyright.com/";
    changelog = "https://github.com/detachhead/basedpyright/releases";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.hasnep ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=detachhead.basedpyright";
  };
}
