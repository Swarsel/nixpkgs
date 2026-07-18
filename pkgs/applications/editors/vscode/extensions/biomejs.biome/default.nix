{
  lib,
  biome,
  jq,
  moreutils,
  vscode-extension-update-script,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  postInstall = ''
    cd "$out/$installPrefix"
    ${lib.getExe jq} '.contributes.configuration.properties."biome.lsp.bin".oneOf[0].default = "${lib.getExe biome}"' package.json | ${lib.getExe' moreutils "sponge"} package.json
  '';

  mktplcRef = {
    version = "2026.6.181955";
    hash = "sha256-6FRrVKDY+E9wuqgeNKArgGn4PDp5ViJsdCPjjwBGbGI=";
    name = "biome";
    publisher = "biomejs";
  };

  passthru.updateScript = vscode-extension-update-script {
    extraArgs = [ "--pre-release" ];
  };

  meta = {
    description = "Biome LSP extension for Visual Studio Code";
    homepage = "https://github.com/biomejs/biome-vscode";
    changelog = "https://github.com/biomejs/biome-vscode/blob/main/CHANGELOG.md";

    license = with lib.licenses; [
      mit
      # or
      asl20
    ];

    maintainers = [ ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=biomejs.biome";
  };
}
