{
  lib,
  vscode-utils,
}:
vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "3.3.4";
    hash = "sha256-qfNz4IYjCmCMFLtAkbGTW5xnsVT8iDnFWjrgkmr2Slk=";
    name = "platformio-ide";
    publisher = "platformio";
  };

  meta = {
    description = "Open source ecosystem for IoT development in VSCode";
    homepage = "https://platformio.org/";
    changelog = "https://marketplace.visualstudio.com/items/platformio.platformio-ide/changelog";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.therobot2105 ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=platformio.platformio-ide";
  };
}
