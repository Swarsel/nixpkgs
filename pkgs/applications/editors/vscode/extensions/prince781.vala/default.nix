{
  lib,
  jq,
  moreutils,
  vala-language-server,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  nativeBuildInputs = [
    jq
    moreutils
  ];

  postInstall = ''
    cd "$out/$installPrefix"
    jq '.contributes.configuration.properties."vala.languageServerPath".default = "${lib.getExe vala-language-server}"' package.json | sponge package.json
  '';

  mktplcRef = {
    version = "1.1.0";
    hash = "sha256-LJJDKhwzbGznyiXeB8SYir3LOM7/quYhGae1m4X/s3M=";
    name = "vala";
    publisher = "prince781";
  };

  meta = {
    description = "Syntax highlighting and language support for the Vala / Genie languages";
    homepage = "https://github.com/vala-lang/vala-vscode#readme";
    changelog = "https://marketplace.visualstudio.com/items/prince781.vala/changelog";
    license = lib.licenses.mit;
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=prince781.vala";
  };
}
