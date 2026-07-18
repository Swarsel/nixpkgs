{
  lib,
  craftos-pc,
  jq,
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

    jq -e '
      .contributes.configuration.properties."craftos-pc.executablePath.linux".default =
        "${lib.meta.getExe craftos-pc}" |
      .contributes.configuration.properties."craftos-pc.executablePath.mac".default =
        "${lib.meta.getExe craftos-pc}" |
      .contributes.configuration.properties."craftos-pc.executablePath.windows".default =
        "${lib.meta.getExe craftos-pc}"
    ' \
    < package.json \
    | sponge package.json
  '';

  mktplcRef = {
    version = "1.2.3";
    hash = "sha256-QoLMefSmownw9AEem0jx1+BF1bcolHYpiqyPKQNkdiQ=";
    name = "craftos-pc";
    publisher = "jackmacwindows";
  };

  meta = {
    description = "Visual Studio Code extension for opening a CraftOS-PC window";
    homepage = "https://www.craftos-pc.cc/docs/extension";
    changelog = "https://marketplace.visualstudio.com/items/jackmacwindows.craftos-pc/changelog";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tomodachi94 ];
    platforms = craftos-pc.meta.platforms;
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=jackmacwindows.craftos-pc";
  };
}
