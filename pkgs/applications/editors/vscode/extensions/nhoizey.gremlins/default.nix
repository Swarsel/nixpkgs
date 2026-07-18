{ lib, vscode-utils }:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "0.26.0";
    hash = "sha256-ML04SccSOrj5qY0HHJ5jiNbWkPElU1+zZNSX2i1K2uk=";
    name = "gremlins";
    publisher = "nhoizey";
  };

  meta = {
    description = "Reveals some characters that can be harmful because they are invisible or looking like legitimate ones";
    homepage = "https://github.com/nhoizey/vscode-gremlins";
    changelog = "https://marketplace.visualstudio.com/items/nhoizey.gremlins/changelog";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.theobori ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=nhoizey.gremlins";
  };
}
