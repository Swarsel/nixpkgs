{
  lib,
  vscode-utils,
}:
let
  version = "4.4.3";
in

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    inherit version;
    hash = "sha256-oY+mpDv2OTy5hFEk2DMNHi9epFm4Ay4qi0drCXPuYhU=";
    name = "vscode-css-peek";
    publisher = "pranaygp";
  };

  meta = {
    description = "Allow peeking to css ID and class strings as definitions from html files to respective CSS";
    homepage = "https://github.com/pranaygp/vscode-css-peek";
    changelog = "https://github.com/pranaygp/vscode-css-peek/blob/v${version}/README.md#changelog";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.kozm9000 ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=pranaygp.vscode-css-peek";
  };
}
