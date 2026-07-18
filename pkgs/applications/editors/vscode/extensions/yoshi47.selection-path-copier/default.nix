{
  lib,
  nix-update-script,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension (finalAttrs: {
  mktplcRef = {
    version = "1.5.0";
    hash = "sha256-ip8dsU8B2vghINPSftvfC5OtM0bjIP0V3JAMt5skmdg=";
    name = "selection-path-copier";
    publisher = "yoshi47";
  };

  meta = {
    description = "Copy file paths with line numbers, code snippets, and GitHub permalinks in multiple formats";
    homepage = "https://github.com/yoshi47/selection-path-copier";
    changelog = "https://github.com/yoshi47/selection-path-copier/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ aduh95 ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=yoshi47.selection-path-copier";
  };
})
