{
  lib,
  direnv,
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
    jq -e '.contributes.configuration.properties."direnv.path.executable".default = "${lib.getExe direnv}"' package.json | sponge package.json
  '';

  mktplcRef = {
    version = "0.17.0";
    hash = "sha256-9sFcfTMeLBGw2ET1snqQ6Uk//D/vcD9AVsZfnUNrWNg=";
    name = "direnv";
    publisher = "mkhl";
  };

  meta = {
    description = "direnv support for Visual Studio Code";
    license = lib.licenses.bsd0;
    maintainers = [ ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=mkhl.direnv";
  };
}
