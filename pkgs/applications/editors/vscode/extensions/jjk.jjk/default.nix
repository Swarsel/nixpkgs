{
  lib,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "0.11.0";
    hash = "sha256-hEgr8u6p2aI5TwjgC+iNF7M5oU+DLLZcw7M88Ech87w=";
    name = "jjk";
    publisher = "jjk";
  };

  meta = {
    description = "Visual Studio Code extension for the Jujutsu (jj) version control system";
    homepage = "https://github.com/keanemind/jjk";
    changelog = "https://github.com/keanemind/jjk/releases";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ilai-deutel ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=jjk.jjk";
  };
}
