{
  lib,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "7.0.3";
    hash = "sha256-Bt31ia0X4sQQfREq8PPVEGt/oGe/Oob0yQbYkwNRSsk=";
    name = "teroshdl";
    publisher = "teros-technology";
  };

  meta = {
    description = "Visual Studio Code extension for HDL developments (SystemVerilog/Verilog/VHDL)";
    homepage = "https://github.com/TerosTechnology/vscode-terosHDL";
    changelog = "https://github.com/TerosTechnology/vscode-terosHDL/releases";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ lheintzmann1 ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=teros-technology.teroshdl";
  };
}
