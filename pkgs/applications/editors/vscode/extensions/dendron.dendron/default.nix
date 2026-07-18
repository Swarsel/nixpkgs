{ lib, vscode-utils }:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "0.124.0";
    hash = "sha256-/hxgmmiMUfBtPt5BcuNvtXs3LzDmPwDuUOyDf2udHws=";
    name = "dendron";
    publisher = "dendron";
  };

  meta = {
    description = "Personal knowledge management (PKM) tool that grows as you do";
    homepage = "https://www.dendron.so/";
    changelog = "https://github.com/dendronhq/dendron/blob/master/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.ivyfanchiang ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=dendron.dendron";
  };
}
