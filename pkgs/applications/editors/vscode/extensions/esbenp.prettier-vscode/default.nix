{
  lib,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "12.4.0";
    hash = "sha256-RtIqVns16+W9/9coBFd0LNZ+ZdfhslC7d1qyvoZHmkI=";
    name = "prettier-vscode";
    publisher = "esbenp";
  };

  meta = {
    description = "Code formatter using prettier";
    homepage = "https://github.com/prettier/prettier-vscode";
    changelog = "https://marketplace.visualstudio.com/items/esbenp.prettier-vscode/changelog";
    license = lib.licenses.mit;
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode";
  };
}
