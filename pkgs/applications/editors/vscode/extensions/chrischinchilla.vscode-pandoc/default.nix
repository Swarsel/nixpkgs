{
  lib,
  jq,
  moreutils,
  pandoc,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  nativeBuildInputs = [
    jq
    moreutils
  ];

  postInstall = ''
    jq '.contributes.configuration.properties."pandoc.executable".default = "${lib.getExe pandoc}"' $out/$installPrefix/package.json | sponge $out/$installPrefix/package.json
  '';

  mktplcRef = {
    version = "0.7.3";
    hash = "sha256-TGkNYA96mzFtUoM+XPKXJ/AM+hbiLc6Lvk5YDxFUwcI=";
    name = "vscode-pandoc";
    publisher = "chrischinchilla";
  };

  meta = {
    description = "Converts Markdown files to pdf, docx, or html files using pandoc";
    homepage = "https://github.com/ChrisChinchilla/vscode-pandoc#readme";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pandapip1 ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=yzane.markdown-pdf";
  };
}
