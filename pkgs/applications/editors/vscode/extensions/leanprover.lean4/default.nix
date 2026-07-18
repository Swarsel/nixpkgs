{
  lib,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "0.0.237";
    hash = "sha256-ti3Hi9YSRu95Srj3cN+kbNfcYWjVLHbC6RIUKnH7sWY=";
    name = "lean4";
    publisher = "leanprover";
  };

  meta = {
    description = "This extension provides VS Code support for the Lean 4 theorem prover and programming language";
    homepage = "https://github.com/leanprover/vscode-lean4";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ alexstaeding ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=leanprover.lean4";
  };
}
