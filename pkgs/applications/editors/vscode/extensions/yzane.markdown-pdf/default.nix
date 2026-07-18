{
  lib,
  jq,
  moreutils,
  ungoogled-chromium,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  nativeBuildInputs = [
    jq
    moreutils
  ];

  postInstall = ''
    jq '.contributes.configuration.properties."markdown-pdf.executablePath".default = "${lib.getExe ungoogled-chromium}"' $out/$installPrefix/package.json | sponge $out/$installPrefix/package.json
  '';

  mktplcRef = {
    version = "2.1.0";
    hash = "sha256-3N4de2jgLbBlDGouFU7XoH4ElL9En9+2ZprMqoL03/E=";
    name = "markdown-pdf";
    publisher = "yzane";
  };

  meta = {
    description = "Converts Markdown files to pdf, html, png or jpeg files";
    homepage = "https://github.com/yzane/vscode-markdown-pdf#readme";
    changelog = "https://github.com/yzane/vscode-markdown-pdf/blob/master/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pandapip1 ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=yzane.markdown-pdf";
  };
}
