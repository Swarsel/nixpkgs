{ lib, vscode-utils }:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "1.1.4";
    hash = "sha256-Hf6UUXShxhFpOG4aaKqHKoyJ0yqFthzNSVW/JZph43c=";
    name = "vscode-man-page-syntax";
    publisher = "motivesoft";
  };

  meta = {
    description = "Syntax highlighting support for manpage authoring";
    homepage = "https://github.com/Motivesoft/vscode-man-page-syntax";
    changelog = "https://github.com/Motivesoft/vscode-man-page-syntax/blob/main/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.iamanaws ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=motivesoft.vscode-man-page-syntax";
  };
}
