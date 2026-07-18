{
  lib,
  jq,
  millet,
  moreutils,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  nativeBuildInputs = [
    jq
    moreutils
  ];

  postInstall = ''
    cd "$out/$installPrefix"
    jq '.contributes.configuration.properties."millet.server.path".default = "${millet}/bin/millet-ls"' package.json | sponge package.json
  '';

  mktplcRef = {
    version = "0.15.2";
    hash = "sha256-mtI4IW+xBIuo11ctTIv5/6LOXVStD3YqSYkIQYJWqmo=";
    name = "Millet";
    publisher = "azdavis";
  };

  meta = {
    description = "Standard ML support for VS Code";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.smasher164 ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=azdavis.millet";
  };
}
