{ lib, vscode-utils }:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "1.8.1";
    hash = "sha256-Apfq0VeLEmXnxsaipA+aJr/QX+chAQQGQQ+64hqFIbA=";
    name = "nimlang";
    publisher = "nimlang";
  };

  meta = {
    description = "Nim language support for VS Code";
    homepage = "https://github.com/nim-lang/vscode-nim";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.therobot2105 ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=nimlang.nimlang";
  };
}
