{
  lib,
  jaq,
  moreutils,
  oxfmt,
  oxlint,
  vscode-utils,
}:
vscode-utils.buildVscodeMarketplaceExtension {
  postPatch = ''
    jaq \
      --arg oxlint "${lib.getExe oxlint}" \
      --arg oxfmt "${lib.getExe oxfmt}" \
      '
        .contributes.configuration.properties."oxc.path.oxlint".default = $oxlint |
        .contributes.configuration.properties."oxc.path.oxfmt".default = $oxfmt
      ' package.json | sponge package.json
  '';

  nativeBuildInputs = [
    jaq
    moreutils
  ];

  mktplcRef = {
    version = "1.58.0";
    hash = "sha256-30dFeguNbY8WM3fLym6aUMkHYH5wA5scSNn04Ukbj9U=";
    name = "oxc-vscode";
    publisher = "oxc";
  };

  meta = {
    description = "Oxlint and Oxfmt editor integration";
    homepage = "https://github.com/oxc-project/oxc-vscode";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.drupol ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=oxc.oxc-vscode";
  };
}
