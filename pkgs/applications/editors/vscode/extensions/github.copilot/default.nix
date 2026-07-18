{
  lib,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    version = "1.388.0";
    hash = "sha256-7RjK8+PNI+rIuRQfCwpvswAiz991dacRO2qYhcv1vhk=";
    name = "copilot";
    publisher = "github";
  };

  meta = {
    description = "GitHub Copilot uses OpenAI Codex to suggest code and entire functions in real-time right from your editor";
    homepage = "https://github.com/features/copilot";
    license = lib.licenses.unfree;
    maintainers = [ lib.maintainers.Zimmi48 ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=GitHub.copilot";
  };
}
