{
  lib,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "1.16.1";
    hash = "sha256-gYfsY5ZwB4vTDplWW49o9EZITY74CfM1FOrCxJ7+g6U=";
    name = "periscope";
    publisher = "joshmu";
  };

  meta = {
    description = "Visual Studio Code extension for fuzzy search and navigation";
    homepage = "https://github.com/joshmu/periscope";
    changelog = "https://marketplace.visualstudio.com/items/joshmu.periscope/changelog";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.smissingham ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=joshmu.periscope";
  };
}
