{
  lib,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "2026.6.0";
    hash = "sha256-zgfBcgIKc78f9qpcl9ULoQTUQ1ETAxfwpH/SSOhyaZc=";
    name = "debugpy";
    publisher = "ms-python";
  };

  meta = {
    description = "Python debugger (debugpy) extension for VS Code";
    homepage = "https://github.com/Microsoft/vscode-python-debugger";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.carlthome ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=ms-python.debugpy";
  };
}
