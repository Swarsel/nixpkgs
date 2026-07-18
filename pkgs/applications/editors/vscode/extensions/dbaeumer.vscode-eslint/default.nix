{
  lib,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "3.0.24";
    hash = "sha256-ZQVzpSSLf3tpO4QtLjbCOje3L5/EqzT9A9IOssl6e54=";
    name = "vscode-eslint";
    publisher = "dbaeumer";
  };

  meta = {
    description = "Integrates ESLint JavaScript into VS Code";
    homepage = "https://github.com/Microsoft/vscode-eslint";
    changelog = "https://marketplace.visualstudio.com/items/dbaeumer.vscode-eslint/changelog";
    license = lib.licenses.mit;
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint";
  };
}
