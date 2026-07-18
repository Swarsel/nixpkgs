{
  lib,
  jq,
  moreutils,
  shellcheck,
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
    jq -e '
      .contributes.configuration.properties."bashIde.shellcheckPath".default = "${lib.getExe shellcheck}" |
      .contributes.configuration.properties."bashIde.shfmt.path".default = "${lib.getExe shfmt}"
    ' package.json | sponge package.json
  '';

  mktplcRef = {
    version = "1.43.0";
    hash = "sha256-IpJCzoYZ+L39HqBts487E00RfVnZhLa9wUYs2FIV9pQ=";
    name = "bash-ide-vscode";
    publisher = "mads-hartmann";
  };

  meta = {
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.kamadorueda ];
  };
}
