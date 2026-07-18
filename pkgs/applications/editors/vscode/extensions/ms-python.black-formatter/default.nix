{
  lib,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "2026.6.0";
    hash = "sha256-jTq5cpP3QwyAOF1VihAJA5ZYCpb3qbmeNIUPFr9Xph8=";
    name = "black-formatter";
    publisher = "ms-python";
  };

  meta = {
    description = "Formatter extension for Visual Studio Code using black";
    homepage = "https://github.com/microsoft/vscode-black-formatter";
    changelog = "https://marketplace.visualstudio.com/items/ms-python.black-formatter/changelog";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      amadejkastelic
      sikmir
    ];

    downloadPage = "https://marketplace.visualstudio.com/items?itemName=ms-python.black-formatter";
  };
}
