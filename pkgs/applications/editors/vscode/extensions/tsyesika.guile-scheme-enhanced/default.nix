{
  lib,
  guile,
  jq,
  moreutils,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  postInstall = ''
    cd "$out/$installPrefix"
    ${lib.getExe jq} '.contributes.configuration.properties."guileScheme.guileREPLCommand".default = "${lib.getExe' guile "guile"}"' package.json | ${lib.getExe' moreutils "sponge"} package.json
  '';

  mktplcRef = {
    version = "0.0.2";
    hash = "sha256-uoHYfbLeANHnMB7OgDQPfIIlNN7LgERS9zQfa+QIk0M=";
    name = "guile-scheme-enhanced";
    publisher = "tsyesika";
  };

  meta = {
    description = "Better experience for working with scheme";
    homepage = "https://codeberg.org/tsyesika/vscode-guile-scheme-enhanced";
    license = lib.licenses.asl20;
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=tsyesika.guile-scheme-enhanced";
  };
}
