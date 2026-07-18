{
  lib,
  harper,
  jq,
  moreutils,
  vscode-extension-update-script,
  vscode-utils,
  ...
}:

vscode-utils.buildVscodeMarketplaceExtension {
  nativeBuildInputs = [
    jq
    moreutils
  ];

  postInstall = ''
    cd "$out/$installPrefix"
    jq '.contributes.configuration.properties."harper.path".default = "${lib.getExe harper}"' package.json | sponge package.json

    rm ./bin/harper-ls
  '';

  mktplcRef = {
    version = harper.version;
    # Because the binary is removed in favor of the harper package,
    # it does not matter which binary is fetched. Using only a single
    # hash makes this easier to maintain.
    arch = "linux-x64";
    hash = "sha256-/brjx/yY4JLLboI6dLwF/eyX7yhRyMlohhGNFGIrm54=";
    name = "harper";
    publisher = "elijah-potter";
  };

  passthru.updateScript = vscode-extension-update-script { };

  meta = {
    description = "The grammar checker for developers as a Visual Studio Code extension";
    homepage = "https://github.com/automattic/harper";
    changelog = "https://github.com/Automattic/harper/releases/tag/v${harper.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ MasterEvarior ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    downloadPage = "https://marketplace.visualstudio.com/items?itemName=elijah-potter.harper";
  };
}
