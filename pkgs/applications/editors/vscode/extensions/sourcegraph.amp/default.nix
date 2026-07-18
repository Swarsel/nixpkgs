{
  lib,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "0.0.1772799397";
    hash = "sha256-O3OnTWazDpdxSQuQo6VS0O8OsfK4WoPMs2w1LCV9Nyc=";
    name = "amp";
    publisher = "sourcegraph";
  };

  meta = {
    description = "Amp is a frontier coding agent for your editor and terminal, built by Sourcegraph.";
    homepage = "https://ampcode.com/";
    license = lib.licenses.unfree;
    maintainers = [ lib.maintainers.katexochen ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=sourcegraph.amp";
  };
}
