{ lib, vscode-utils }:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "1.12.1";
    hash = "sha256-ioK6gwtkaAcfxn11lqpwhrpILSfft/byeEqoEtJIfM0=";
    name = "cortex-debug";
    publisher = "marus25";
  };

  meta = {
    description = "Visual Studio Code extension for enhancing debug capabilities for Cortex-M Microcontrollers";
    homepage = "https://github.com/Marus/cortex-debug";
    changelog = "https://marketplace.visualstudio.com/items/marus25.cortex-debug/changelog";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.bcooley ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=marus25.cortex-debug";
  };
}
