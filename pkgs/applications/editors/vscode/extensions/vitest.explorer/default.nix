{ lib, vscode-utils }:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "1.50.2";
    hash = "sha256-9AmJa3vMXBx2VC20j7bGyIoascQd7SvvFTgfyBi7SLU=";
    name = "explorer";
    publisher = "vitest";
  };

  meta = {
    description = "Vitest extension for Visual Studio Code";
    homepage = "https://github.com/vitest-dev/vscode";
    changelog = "https://github.com/vitest-dev/vscode/releases";
    license = lib.licenses.mit;
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=vitest.explorer";
  };
}
