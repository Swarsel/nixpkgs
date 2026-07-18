{
  lib,
  jq,
  moreutils,
  shfmt,
  vscode-utils,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  nativeBuildInputs = [
    jq
    moreutils
  ];

  postInstall = ''
    cd "$out/$installPrefix"
    jq '.contributes.configuration.properties."shellformat.path".default = "${shfmt}/bin/shfmt"' package.json | sponge package.json
  '';

  mktplcRef = {
    version = "7.2.5";
    hash = "sha256-kfpRByJDcGY3W9+ELBzDOUMl06D/vyPlN//wPgQhByk=";
    name = "shell-format";
    publisher = "foxundermoon";
  };

  meta = {
    homepage = "https://github.com/foxundermoon/vs-shell-format";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dbirks ];
    downloadPage = "https://marketplace.visualstudio.com/items?itemName=foxundermoon.shell-format";
  };
}
