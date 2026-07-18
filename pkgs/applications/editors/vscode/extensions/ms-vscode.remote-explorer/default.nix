{
  lib,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "0.5.0";
    name = "remote-explorer";
    publisher = "ms-vscode";
    sha256 = "sha256-BNsnetpddxv3Y9MjZERU5jOq1I2g6BNFF1rD7Agpmr8=";
  };

  meta = {
    description = "Visual Studio Code extension to view remote machines for SSH and Tunnels";
    homepage = "https://github.com/Microsoft/vscode-remote-release";
    license = lib.licenses.unfree;
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=ms-vscode.remote-explorer";
  };
}
