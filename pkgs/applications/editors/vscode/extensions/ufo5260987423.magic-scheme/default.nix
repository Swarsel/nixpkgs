{
  lib,
  akku,
  akkuPackages,
  chez,
  jq,
  moreutils,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  postInstall = ''
    cd "$out/$installPrefix"
    ${lib.getExe jq} '.contributes.configuration.properties."magicScheme.scheme-langserver.serverPath".default = "${lib.getExe' akkuPackages.scheme-langserver "scheme-langserver"}" | .contributes.configuration.properties."magicScheme.scheme.path".default = "${lib.getExe' chez "scheme"}" | .contributes.configuration.properties."magicScheme.akku.path".default = "${lib.getExe akku}"' package.json | ${lib.getExe' moreutils "sponge"} package.json
  '';

  mktplcRef = {
    version = "0.0.6";
    hash = "sha256-ibEdsw/ulr+cagB90uALDbSsQV18dPULANCdnjPvhuI=";
    name = "magic-scheme";
    publisher = "ufo5260987423";
  };

  meta = {
    description = "Adds support for Scheme(r6rs standard)";
    homepage = "https://github.com/ufo5260987423/magic-scheme";
    license = lib.licenses.mit;
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=ufo5260987423.magic-scheme";
  };
}
