{
  lib,
  vscode-utils,
}:
vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "0.0.7";
    hash = "sha256-j0Dj7YiawhPAMHe8wk8Ph4vo26IneidoGJ4C9O7Z/64=";
    name = "reload";
    publisher = "natqe";
  };

  meta = {
    description = "This extension will add reload button to status bar in the right-bottom of your VSCode editor";
    homepage = "https://github.com/natqe/reload";
    license = lib.licenses.unfree;
    maintainers = [ lib.maintainers.therobot2105 ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=natqe.reload";
  };
}
