{
  lib,
  buildPackages,
  python3,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  postInstall = ''
    cd "$out/$installPrefix"
    ${lib.getExe buildPackages.jq} '.contributes.configuration.properties."scheme-fmt.pythonPath".default = "${lib.getExe python3}"' package.json | ${lib.getExe' buildPackages.moreutils "sponge"} package.json
  '';

  mktplcRef = {
    version = "1.2.1";
    hash = "sha256-oTXy0Vjd0s7ZYZzr36ILQOJm4BW9Qd7y8fGbnhkaD1Y=";
    name = "scheme-fmt";
    publisher = "oliver-ni";
  };

  meta = {
    description = "Formats Scheme source code";
    homepage = "https://github.com/oliver-ni/scheme-fmt";
    license = lib.licenses.cc0;
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=oliver-ni.scheme-fmt";
  };
}
