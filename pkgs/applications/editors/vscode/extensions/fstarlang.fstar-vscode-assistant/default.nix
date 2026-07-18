{ lib, vscode-utils }:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "0.25.4";
    hash = "sha256-9gPM/T3Kbwt40V2ZuzN/OkQVNATsp4AYK9HuOu/Ui+0=";
    name = "fstar-vscode-assistant";
    publisher = "FStarLang";
  };

  meta = {
    description = "Interactive editing mode VS Code extension for F*";
    homepage = "https://github.com/FStarLang/fstar-vscode-assistant";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.parrot7483 ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=FStarLang.fstar-vscode-assistant";
  };
}
