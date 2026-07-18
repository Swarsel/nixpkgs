{
  lib,
  vscode-utils,
}:
vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "1.13.0";
    hash = "sha256-3hyKKAMUy4kXGRWBQCL4adV1W6xtgS1OYhJJYSzswbo=";
    name = "robotframework-lsp";
    publisher = "robocorp";
  };

  meta = {
    description = "VSCode extension for providing an integration solution for Typst";
    homepage = "https://github.com/myriad-dreamin/tinymist";
    changelog = "https://marketplace.visualstudio.com/items/myriad-dreamin.tinymist/changelog";
    license = lib.licenses.asl20;
    maintainers = [ ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=myriad-dreamin.tinymist";
  };
}
