{
  lib,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "1.6.2";
    hash = "sha256-irI7rcyCUc3jUhrEa449pDix3MhwMh18ezvri3bi0Gk=";
    name = "windows-ai-studio";
    publisher = "ms-windows-ai-studio";
  };

  meta = {
    description = "Visual Studio Code extension to help developers and AI engineers build AI apps";
    homepage = "https://github.com/Microsoft/windows-ai-studio";
    license = lib.licenses.unfree;
    maintainers = [ ];
  };
}
